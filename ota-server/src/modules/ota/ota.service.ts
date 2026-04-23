import { createHash, createHmac, timingSafeEqual } from 'node:crypto';
import { ForbiddenException, HttpException, HttpStatus, Injectable, UnauthorizedException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { env } from '../../config/env';
import { HeartbeatDto } from './dto/heartbeat.dto';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { UpdateQueryDto } from './dto/update-query.dto';
import { PrismaService } from '../prisma/prisma.service';

type OtaRequestMeta = {
  ipAddress: string | null;
  signature: string | null;
  timestamp: string | null;
};

type DeviceContext = Prisma.DeviceGetPayload<{
  include: {
    groupMemberships: true;
    tagMemberships: true;
  };
}>;

type CampaignCandidate = Prisma.CampaignGetPayload<{
  include: {
    release: { include: { files: true } };
    targetRules: true;
  };
}>;

@Injectable()
export class OtaService {
  private readonly rateBuckets = new Map<string, { startedAtMs: number; count: number }>();

  constructor(private readonly prisma: PrismaService) {}

  async register(body: RegisterDeviceDto, meta: OtaRequestMeta) {
    this.enforceRateLimit('register', body.token, meta.ipAddress);
    this.verifySignature('register', [body.token, body.model, body.version, body.mac, body.board], meta);

    const now = new Date();
    const firmwareModelId = await this.resolveFirmwareModelId(body.model, body.board);

    const device = await this.prisma.device.upsert({
      where: { token: body.token },
      update: {
        model: body.model,
        mac: body.mac,
        board: body.board,
        firmwareModelId,
        currentVersion: body.version,
        lastSeenAt: now,
        status: 'registered',
        lastResult: 'register_ok',
        lastError: null,
        lastIp: meta.ipAddress,
      },
      create: {
        token: body.token,
        model: body.model,
        mac: body.mac,
        board: body.board,
        firmwareModelId,
        currentVersion: body.version,
        firstRegisteredAt: now,
        lastSeenAt: now,
        status: 'registered',
        lastResult: 'register_ok',
        lastIp: meta.ipAddress,
      },
    });

    await this.markDeliveredCampaigns(device.id, body.version);

    await this.recordEvent(device.id, 'register', 'ok', 'device registered or refreshed', this.toJsonObject(body));

    return {
      accepted: true,
      device_id: device.id,
    };
  }

  async checkUpdate(query: UpdateQueryDto, meta: OtaRequestMeta) {
    this.enforceRateLimit('update', query.token, meta.ipAddress);
    this.verifySignature('update', [query.token, query.model, query.version, query.mac, query.board], meta);
    const firmwareModelId = await this.resolveFirmwareModelId(query.model, query.board);

    const device = await this.prisma.device.findUnique({
      where: { token: query.token },
    });

    if (!device) {
      throw new ForbiddenException('unknown token');
    }

    if (device.model !== query.model) {
      await this.recordEvent(
        device.id,
        'update_check',
        'model_mismatch',
        `token model mismatch: expected ${device.model}, got ${query.model}`,
        this.toJsonObject(query),
      );

      throw new ForbiddenException('token and model mismatch');
    }

    await this.prisma.device.update({
      where: { id: device.id },
      data: {
        model: query.model,
        mac: query.mac,
        board: query.board,
        firmwareModelId,
        currentVersion: query.version,
        lastSeenAt: new Date(),
        lastIp: meta.ipAddress,
        status: 'checking',
      },
    });

    const deviceContext = await this.prisma.device.findUnique({
      where: {
        id: device.id,
      },
      include: {
        groupMemberships: true,
        tagMemberships: true,
      },
    });

    if (!deviceContext) {
      throw new ForbiddenException('unknown token');
    }

    const campaign = await this.findMatchingCampaign(deviceContext, query.model, query.version, 'stable');

    if (campaign) {
      return this.buildCampaignUpdateResponse(device.id, query, campaign);
    }

    const release = await this.prisma.release.findFirst({
      where: {
        active: true,
        model: query.model,
        channel: 'stable',
      },
      include: {
        files: true,
      },
      orderBy: [
        { createdAt: 'desc' },
        { id: 'desc' },
      ],
    });

    if (!release || release.version === query.version) {
      await this.prisma.device.update({
        where: { id: device.id },
        data: {
          status: 'idle',
          lastResult: 'up_to_date',
          lastError: null,
        },
      });

      await this.recordEvent(
        device.id,
        'update_check',
        'up_to_date',
        'no newer release available',
        this.toJsonObject(query),
      );

      return {
        update_available: false,
      };
    }

    const downloadUrls = this.collectDownloadUrls(release);
    const primaryFile = release.files.find((file) => file.url === downloadUrls[0]) ?? release.files[0];

    await this.prisma.device.update({
      where: { id: device.id },
      data: {
        status: 'available',
        lastResult: 'update_available',
        lastError: null,
      },
    });

    await this.recordEvent(
      device.id,
      'update_check',
      'available',
      `release ${release.version} available`,
      this.toJsonObject(query),
    );

    return {
      update_available: true,
      version: release.version,
      download_url: downloadUrls[0],
      download_urls: downloadUrls,
      size_bytes: primaryFile?.sizeBytes != null ? Number(primaryFile.sizeBytes) : null,
      sha256: release.sha256,
      changelog: release.changelog ?? '',
      force: release.force,
      rollout_percent: release.rolloutPercent,
    };
  }

  async heartbeat(body: HeartbeatDto, meta: OtaRequestMeta) {
    this.enforceRateLimit('heartbeat', body.token, meta.ipAddress);
    this.verifySignature(
      'heartbeat',
      [body.token, body.status, body.current_version, body.last_result ?? '', body.last_error ?? ''],
      meta,
    );

    const device = await this.prisma.device.findUnique({
      where: { token: body.token },
    });

    if (!device) {
      throw new ForbiddenException('unknown token');
    }

    await this.prisma.device.update({
      where: { id: device.id },
      data: {
        status: body.status,
        currentVersion: body.current_version,
        lastResult: body.last_result ?? null,
        lastError: body.last_error ?? null,
        lastSeenAt: new Date(),
        lastIp: meta.ipAddress,
      },
    });

    await this.updateLatestCampaignState(device.id, body.current_version, body.status);

    await this.recordEvent(device.id, 'heartbeat', body.status, 'device heartbeat received', this.toJsonObject(body));

    return {
      ok: true,
    };
  }

  private collectDownloadUrls(release: {
    downloadUrl: string;
    files: Array<{ url: string }>;
  }): string[] {
    const urls = [release.downloadUrl, ...release.files.map((file) => file.url)].filter(Boolean);

    return Array.from(new Set(urls));
  }

  private async buildCampaignUpdateResponse(deviceId: number, query: UpdateQueryDto, campaign: CampaignCandidate) {
    const downloadUrls = this.collectDownloadUrls(campaign.release);
    const primaryFile = campaign.release.files.find((file) => file.url === downloadUrls[0]) ?? campaign.release.files[0];
    const now = new Date();

    await this.prisma.device.update({
      where: {
        id: deviceId,
      },
      data: {
        status: 'available',
        lastResult: 'update_available',
        lastError: null,
      },
    });

    await this.prisma.campaignDevice.upsert({
      where: {
        campaignId_deviceId: {
          campaignId: campaign.id,
          deviceId,
        },
      },
      update: {
        eligibilityStatus: 'matched',
        updateStatus: 'available',
        lastEvaluatedAt: now,
        matchedAt: now,
      },
      create: {
        campaignId: campaign.id,
        deviceId,
        eligibilityStatus: 'matched',
        updateStatus: 'available',
        lastEvaluatedAt: now,
        matchedAt: now,
      },
    });

    await this.recordEvent(
      deviceId,
      'campaign_match',
      'available',
      `campaign ${campaign.name} matched release ${campaign.release.version}`,
      this.toJsonObject({
        campaign_id: campaign.id,
        release_id: campaign.release.id,
        release_version: campaign.release.version,
        token: query.token,
      }),
    );

    return {
      update_available: true,
      version: campaign.release.version,
      download_url: downloadUrls[0],
      download_urls: downloadUrls,
      size_bytes: primaryFile?.sizeBytes != null ? Number(primaryFile.sizeBytes) : null,
      sha256: campaign.release.sha256,
      changelog: campaign.release.changelog ?? '',
      force: campaign.release.force,
      rollout_percent: campaign.rolloutPercent,
      campaign: {
        id: campaign.id,
        name: campaign.name,
        priority: campaign.priority,
      },
    };
  }

  private async findMatchingCampaign(
    device: DeviceContext,
    model: string,
    currentVersion: string,
    channel: string,
  ): Promise<CampaignCandidate | null> {
    const now = new Date();
    const campaigns = await this.prisma.campaign.findMany({
      where: {
        active: true,
        channel,
        OR: [
          { startAt: null },
          { startAt: { lte: now } },
        ],
        AND: [
          {
            OR: [
              { endAt: null },
              { endAt: { gte: now } },
            ],
          },
        ],
        release: {
          model,
        },
      },
      include: {
        release: {
          include: {
            files: true,
          },
        },
        targetRules: true,
      },
      orderBy: [
        { priority: 'desc' },
        { createdAt: 'desc' },
      ],
    });

    for (const campaign of campaigns) {
      if (campaign.release.version === currentVersion) {
        await this.recordCampaignState(campaign.id, device.id, 'already_current');
        continue;
      }

      if (!this.matchesCampaignRules(campaign, device)) {
        await this.recordCampaignState(campaign.id, device.id, 'filtered');
        continue;
      }

      if (!this.isRolloutEligible(device.token, campaign.rolloutPercent)) {
        await this.recordCampaignState(campaign.id, device.id, 'rollout_hold');
        continue;
      }

      return campaign;
    }

    return null;
  }

  private matchesCampaignRules(campaign: CampaignCandidate, device: DeviceContext): boolean {
    const includeRules = campaign.targetRules.filter((rule) => !rule.isExclude);
    const excludeRules = campaign.targetRules.filter((rule) => rule.isExclude);

    const included = includeRules.every((rule) => this.matchesTargetRule(rule, device));
    const excluded = excludeRules.some((rule) => this.matchesTargetRule(rule, device));

    return included && !excluded;
  }

  private matchesTargetRule(rule: CampaignCandidate['targetRules'][number], device: DeviceContext): boolean {
    switch (rule.ruleType) {
      case 'group':
        return rule.groupId != null && device.groupMemberships.some((membership) => membership.groupId === rule.groupId);
      case 'tag':
        return rule.tagId != null && device.tagMemberships.some((membership) => membership.tagId === rule.tagId);
      case 'current_version':
        return this.compareStringValue(device.currentVersion ?? '', rule.operator, rule.valueString, rule.valueJson);
      case 'mac':
        return this.compareStringValue(device.mac, rule.operator, rule.valueString, rule.valueJson);
      case 'token':
        return this.compareStringValue(device.token, rule.operator, rule.valueString, rule.valueJson);
      case 'model':
        return this.compareStringValue(device.model, rule.operator, rule.valueString, rule.valueJson);
      case 'board':
        return this.compareStringValue(device.board, rule.operator, rule.valueString, rule.valueJson);
      default:
        return false;
    }
  }

  private compareStringValue(
    actual: string,
    operator: string,
    expected: string | null,
    expectedJson: Prisma.JsonValue | null,
  ): boolean {
    const normalizedActual = actual.toLowerCase();
    const normalizedExpected = expected?.toLowerCase() ?? '';

    switch (operator) {
      case 'eq':
        return normalizedActual === normalizedExpected;
      case 'neq':
        return normalizedActual !== normalizedExpected;
      case 'contains':
        return normalizedExpected.length > 0 && normalizedActual.includes(normalizedExpected);
      case 'prefix':
        return normalizedExpected.length > 0 && normalizedActual.startsWith(normalizedExpected);
      case 'in':
        return Array.isArray(expectedJson)
          && expectedJson.some((value) => typeof value === 'string' && value.toLowerCase() === normalizedActual);
      default:
        return false;
    }
  }

  private isRolloutEligible(token: string, rolloutPercent: number): boolean {
    const normalizedPercent = Math.max(1, Math.min(100, rolloutPercent));
    const hash = createHash('sha256').update(token).digest();
    const bucket = hash.readUInt16BE(0) % 100;

    return bucket < normalizedPercent;
  }

  private async recordCampaignState(campaignId: number, deviceId: number, eligibilityStatus: string) {
    await this.prisma.campaignDevice.upsert({
      where: {
        campaignId_deviceId: {
          campaignId,
          deviceId,
        },
      },
      update: {
        eligibilityStatus,
        lastEvaluatedAt: new Date(),
      },
      create: {
        campaignId,
        deviceId,
        eligibilityStatus,
        lastEvaluatedAt: new Date(),
      },
    });
  }

  private async resolveFirmwareModelId(model: string, board: string): Promise<number | null> {
    const firmwareModel = await this.prisma.firmwareModel.findFirst({
      where: {
        active: true,
        OR: [
          {
            modelKey: model,
          },
          {
            boardIdentifier: board,
          },
        ],
      },
      select: {
        id: true,
      },
    });

    return firmwareModel?.id ?? null;
  }

  private async markDeliveredCampaigns(deviceId: number, currentVersion: string) {
    const activeStates = await this.prisma.campaignDevice.findMany({
      where: {
        deviceId,
        eligibilityStatus: 'matched',
        deliveredAt: null,
        campaign: {
          release: {
            version: currentVersion,
          },
        },
      },
      select: {
        id: true,
      },
    });

    if (activeStates.length === 0) {
      return;
    }

    await this.prisma.campaignDevice.updateMany({
      where: {
        id: {
          in: activeStates.map((state) => state.id),
        },
      },
      data: {
        updateStatus: 'delivered',
        deliveredAt: new Date(),
      },
    });
  }

  private async updateLatestCampaignState(deviceId: number, currentVersion: string, status: string) {
    const latestState = await this.prisma.campaignDevice.findFirst({
      where: {
        deviceId,
        eligibilityStatus: 'matched',
      },
      include: {
        campaign: {
          include: {
            release: true,
          },
        },
      },
      orderBy: [
        { matchedAt: 'desc' },
        { id: 'desc' },
      ],
    });

    if (!latestState) {
      return;
    }

    await this.prisma.campaignDevice.update({
      where: {
        id: latestState.id,
      },
      data: {
        updateStatus: status,
        deliveredAt: latestState.campaign.release.version === currentVersion ? new Date() : latestState.deliveredAt,
      },
    });
  }

  private async recordEvent(
    deviceId: number,
    eventType: string,
    status: string,
    message: string,
    payload: Prisma.InputJsonObject,
  ) {
    await this.prisma.deviceEvent.create({
      data: {
        deviceId,
        eventType,
        status,
        message,
        payloadJson: payload,
      },
    });
  }

  private toJsonObject(payload: object): Prisma.InputJsonObject {
    return Object.fromEntries(
      Object.entries(payload).map(([key, value]) => [key, value ?? null]),
    ) as Prisma.InputJsonObject;
  }

  private enforceRateLimit(endpoint: string, token: string, ipAddress: string | null) {
    const windowMs = env.OTA_RATE_LIMIT_WINDOW_SECONDS * 1000;
    const key = `${endpoint}:${token}:${ipAddress ?? '-'}`;
    const now = Date.now();
    const bucket = this.rateBuckets.get(key);

    if (!bucket || now - bucket.startedAtMs >= windowMs) {
      this.rateBuckets.set(key, { startedAtMs: now, count: 1 });
      return;
    }

    if (bucket.count >= env.OTA_RATE_LIMIT_MAX_REQUESTS) {
      throw new HttpException('ota rate limit exceeded', HttpStatus.TOO_MANY_REQUESTS);
    }

    bucket.count += 1;
    this.rateBuckets.set(key, bucket);
  }

  private verifySignature(endpoint: string, parts: string[], meta: OtaRequestMeta) {
    if (!env.OTA_HMAC_SECRET) {
      return;
    }

    if (!meta.signature || !meta.timestamp) {
      throw new UnauthorizedException('missing ota signature headers');
    }

    const ts = Number(meta.timestamp);
    if (!Number.isFinite(ts)) {
      throw new UnauthorizedException('invalid ota signature timestamp');
    }

    const now = Math.floor(Date.now() / 1000);
    if (Math.abs(now - ts) > env.OTA_HMAC_MAX_SKEW_SECONDS) {
      throw new UnauthorizedException('ota signature timestamp expired');
    }

    const data = `${meta.timestamp}|${endpoint}|${parts.join('|')}`;
    const expected = createHmac('sha256', env.OTA_HMAC_SECRET).update(data).digest('hex');

    const actualBuf = Buffer.from(meta.signature, 'hex');
    const expectedBuf = Buffer.from(expected, 'hex');
    if (actualBuf.length !== expectedBuf.length || !timingSafeEqual(actualBuf, expectedBuf)) {
      throw new UnauthorizedException('invalid ota signature');
    }
  }
}
