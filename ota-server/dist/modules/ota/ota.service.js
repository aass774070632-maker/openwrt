"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OtaService = void 0;
const node_crypto_1 = require("node:crypto");
const common_1 = require("@nestjs/common");
const env_1 = require("../../config/env");
const prisma_service_1 = require("../prisma/prisma.service");
let OtaService = class OtaService {
    constructor(prisma) {
        this.prisma = prisma;
        this.rateBuckets = new Map();
    }
    async register(body, meta) {
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
    async checkUpdate(query, meta) {
        this.enforceRateLimit('update', query.token, meta.ipAddress);
        this.verifySignature('update', [query.token, query.model, query.version, query.mac, query.board], meta);
        const firmwareModelId = await this.resolveFirmwareModelId(query.model, query.board);
        const device = await this.prisma.device.findUnique({
            where: { token: query.token },
        });
        if (!device) {
            throw new common_1.ForbiddenException('unknown token');
        }
        if (device.model !== query.model) {
            await this.recordEvent(device.id, 'update_check', 'model_mismatch', `token model mismatch: expected ${device.model}, got ${query.model}`, this.toJsonObject(query));
            throw new common_1.ForbiddenException('token and model mismatch');
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
            throw new common_1.ForbiddenException('unknown token');
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
            await this.recordEvent(device.id, 'update_check', 'up_to_date', 'no newer release available', this.toJsonObject(query));
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
        await this.recordEvent(device.id, 'update_check', 'available', `release ${release.version} available`, this.toJsonObject(query));
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
    async heartbeat(body, meta) {
        this.enforceRateLimit('heartbeat', body.token, meta.ipAddress);
        this.verifySignature('heartbeat', [body.token, body.status, body.current_version, body.last_result ?? '', body.last_error ?? ''], meta);
        const device = await this.prisma.device.findUnique({
            where: { token: body.token },
        });
        if (!device) {
            throw new common_1.ForbiddenException('unknown token');
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
    collectDownloadUrls(release) {
        const urls = [release.downloadUrl, ...release.files.map((file) => file.url)].filter(Boolean);
        return Array.from(new Set(urls));
    }
    async buildCampaignUpdateResponse(deviceId, query, campaign) {
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
        await this.recordEvent(deviceId, 'campaign_match', 'available', `campaign ${campaign.name} matched release ${campaign.release.version}`, this.toJsonObject({
            campaign_id: campaign.id,
            release_id: campaign.release.id,
            release_version: campaign.release.version,
            token: query.token,
        }));
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
    async findMatchingCampaign(device, model, currentVersion, channel) {
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
    matchesCampaignRules(campaign, device) {
        const includeRules = campaign.targetRules.filter((rule) => !rule.isExclude);
        const excludeRules = campaign.targetRules.filter((rule) => rule.isExclude);
        const included = includeRules.every((rule) => this.matchesTargetRule(rule, device));
        const excluded = excludeRules.some((rule) => this.matchesTargetRule(rule, device));
        return included && !excluded;
    }
    matchesTargetRule(rule, device) {
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
    compareStringValue(actual, operator, expected, expectedJson) {
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
    isRolloutEligible(token, rolloutPercent) {
        const normalizedPercent = Math.max(1, Math.min(100, rolloutPercent));
        const hash = (0, node_crypto_1.createHash)('sha256').update(token).digest();
        const bucket = hash.readUInt16BE(0) % 100;
        return bucket < normalizedPercent;
    }
    async recordCampaignState(campaignId, deviceId, eligibilityStatus) {
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
    async resolveFirmwareModelId(model, board) {
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
    async markDeliveredCampaigns(deviceId, currentVersion) {
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
    async updateLatestCampaignState(deviceId, currentVersion, status) {
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
    async recordEvent(deviceId, eventType, status, message, payload) {
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
    toJsonObject(payload) {
        return Object.fromEntries(Object.entries(payload).map(([key, value]) => [key, value ?? null]));
    }
    enforceRateLimit(endpoint, token, ipAddress) {
        const windowMs = env_1.env.OTA_RATE_LIMIT_WINDOW_SECONDS * 1000;
        const key = `${endpoint}:${token}:${ipAddress ?? '-'}`;
        const now = Date.now();
        const bucket = this.rateBuckets.get(key);
        if (!bucket || now - bucket.startedAtMs >= windowMs) {
            this.rateBuckets.set(key, { startedAtMs: now, count: 1 });
            return;
        }
        if (bucket.count >= env_1.env.OTA_RATE_LIMIT_MAX_REQUESTS) {
            throw new common_1.HttpException('ota rate limit exceeded', common_1.HttpStatus.TOO_MANY_REQUESTS);
        }
        bucket.count += 1;
        this.rateBuckets.set(key, bucket);
    }
    verifySignature(endpoint, parts, meta) {
        if (!env_1.env.OTA_HMAC_SECRET) {
            return;
        }
        if (!meta.signature || !meta.timestamp) {
            throw new common_1.UnauthorizedException('missing ota signature headers');
        }
        const ts = Number(meta.timestamp);
        if (!Number.isFinite(ts)) {
            throw new common_1.UnauthorizedException('invalid ota signature timestamp');
        }
        const now = Math.floor(Date.now() / 1000);
        if (Math.abs(now - ts) > env_1.env.OTA_HMAC_MAX_SKEW_SECONDS) {
            throw new common_1.UnauthorizedException('ota signature timestamp expired');
        }
        const data = `${meta.timestamp}|${endpoint}|${parts.join('|')}`;
        const expected = (0, node_crypto_1.createHmac)('sha256', env_1.env.OTA_HMAC_SECRET).update(data).digest('hex');
        const actualBuf = Buffer.from(meta.signature, 'hex');
        const expectedBuf = Buffer.from(expected, 'hex');
        if (actualBuf.length !== expectedBuf.length || !(0, node_crypto_1.timingSafeEqual)(actualBuf, expectedBuf)) {
            throw new common_1.UnauthorizedException('invalid ota signature');
        }
    }
};
exports.OtaService = OtaService;
exports.OtaService = OtaService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], OtaService);
//# sourceMappingURL=ota.service.js.map