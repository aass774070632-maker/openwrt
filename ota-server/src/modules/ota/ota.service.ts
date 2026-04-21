import { ForbiddenException, Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { HeartbeatDto } from './dto/heartbeat.dto';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { UpdateQueryDto } from './dto/update-query.dto';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class OtaService {
  constructor(private readonly prisma: PrismaService) {}

  async register(body: RegisterDeviceDto) {
    const now = new Date();

    const device = await this.prisma.device.upsert({
      where: { token: body.token },
      update: {
        model: body.model,
        mac: body.mac,
        board: body.board,
        currentVersion: body.version,
        lastSeenAt: now,
        status: 'registered',
        lastResult: 'register_ok',
        lastError: null,
      },
      create: {
        token: body.token,
        model: body.model,
        mac: body.mac,
        board: body.board,
        currentVersion: body.version,
        firstRegisteredAt: now,
        lastSeenAt: now,
        status: 'registered',
        lastResult: 'register_ok',
      },
    });

    await this.recordEvent(device.id, 'register', 'ok', 'device registered or refreshed', this.toJsonObject(body));

    return {
      accepted: true,
      device_id: device.id,
    };
  }

  async checkUpdate(query: UpdateQueryDto) {
    const device = await this.prisma.device.findUnique({
      where: { token: query.token },
    });

    if (!device) {
      throw new ForbiddenException('unknown token');
    }

    await this.prisma.device.update({
      where: { id: device.id },
      data: {
        model: query.model,
        mac: query.mac,
        board: query.board,
        currentVersion: query.version,
        lastSeenAt: new Date(),
        status: 'checking',
      },
    });

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
      sha256: release.sha256,
      changelog: release.changelog ?? '',
      force: release.force,
      rollout_percent: release.rolloutPercent,
    };
  }

  async heartbeat(body: HeartbeatDto) {
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
      },
    });

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
}
