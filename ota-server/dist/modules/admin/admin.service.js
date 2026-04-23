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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AdminService = void 0;
const common_1 = require("@nestjs/common");
const client_1 = require("@prisma/client");
const node_crypto_1 = require("node:crypto");
const promises_1 = require("node:fs/promises");
const node_path_1 = __importDefault(require("node:path"));
const env_1 = require("../../config/env");
const prisma_service_1 = require("../prisma/prisma.service");
let AdminService = class AdminService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async getDashboardSummary() {
        const last24Hours = new Date(Date.now() - 24 * 60 * 60 * 1000);
        const [totalDevices, onlineDevices, activeCampaigns, totalModels, totalReleases, devices, recentErrors,] = await this.prisma.$transaction([
            this.prisma.device.count(),
            this.prisma.device.count({
                where: {
                    lastSeenAt: {
                        gte: last24Hours,
                    },
                },
            }),
            this.prisma.campaign.count({
                where: {
                    active: true,
                    archivedAt: null,
                },
            }),
            this.prisma.firmwareModel.count(),
            this.prisma.release.count(),
            this.prisma.device.findMany({
                select: {
                    model: true,
                    currentVersion: true,
                },
            }),
            this.prisma.device.findMany({
                where: {
                    lastError: {
                        not: null,
                    },
                },
                select: {
                    id: true,
                    model: true,
                    mac: true,
                    lastError: true,
                    lastSeenAt: true,
                },
                orderBy: [
                    { updatedAt: 'desc' },
                    { id: 'desc' },
                ],
                take: 5,
            }),
        ]);
        const byVersion = new Map();
        const byModel = new Map();
        for (const device of devices) {
            const versionKey = device.currentVersion ?? 'unknown';
            byVersion.set(versionKey, (byVersion.get(versionKey) ?? 0) + 1);
            byModel.set(device.model, (byModel.get(device.model) ?? 0) + 1);
        }
        return {
            counts: {
                total_devices: totalDevices,
                online_last_24h: onlineDevices,
                active_campaigns: activeCampaigns,
                firmware_models: totalModels,
                releases: totalReleases,
            },
            versions: Array.from(byVersion.entries())
                .map(([version, count]) => ({ version, count }))
                .sort((left, right) => right.count - left.count),
            models: Array.from(byModel.entries())
                .map(([model, count]) => ({ model, count }))
                .sort((left, right) => right.count - left.count),
            recent_errors: recentErrors.map((device) => ({
                id: device.id,
                model: device.model,
                mac: device.mac,
                last_error: device.lastError,
                last_seen_at: device.lastSeenAt?.toISOString() ?? null,
            })),
        };
    }
    async listDevices() {
        const devices = await this.prisma.device.findMany({
            include: {
                firmwareModel: true,
                groupMemberships: {
                    include: {
                        group: true,
                    },
                },
                tagMemberships: {
                    include: {
                        tag: true,
                    },
                },
            },
            orderBy: [
                { lastSeenAt: 'desc' },
                { id: 'desc' },
            ],
        });
        return devices.map((device) => this.serializeDevice(device));
    }
    async listFirmwareModels() {
        const models = await this.prisma.firmwareModel.findMany({
            include: {
                _count: {
                    select: {
                        devices: true,
                        releases: true,
                    },
                },
            },
            orderBy: [
                { displayName: 'asc' },
                { id: 'asc' },
            ],
        });
        return models.map((model) => this.serializeFirmwareModel(model));
    }
    async createFirmwareModel(body, adminUserId) {
        const slug = this.normalizeSlug(body.slug ?? body.model_key);
        const model = await this.prisma.$transaction(async (tx) => {
            const created = await tx.firmwareModel.create({
                data: {
                    slug,
                    modelKey: body.model_key.trim(),
                    displayName: body.display_name.trim(),
                    boardIdentifier: body.board_identifier?.trim() || null,
                    artifactKind: body.artifact_kind?.trim() || 'sysupgrade',
                    notes: body.notes?.trim() || null,
                    active: body.active ?? true,
                },
                include: {
                    _count: {
                        select: {
                            devices: true,
                            releases: true,
                        },
                    },
                },
            });
            const deviceMatchClauses = [
                {
                    model: created.modelKey,
                },
            ];
            if (created.boardIdentifier) {
                deviceMatchClauses.push({
                    board: created.boardIdentifier,
                });
            }
            await tx.device.updateMany({
                where: {
                    firmwareModelId: null,
                    OR: deviceMatchClauses,
                },
                data: {
                    firmwareModelId: created.id,
                },
            });
            await tx.release.updateMany({
                where: {
                    model: created.modelKey,
                    firmwareModelId: null,
                },
                data: {
                    firmwareModelId: created.id,
                },
            });
            return created;
        });
        await this.recordAudit(adminUserId, 'firmware_model.create', 'firmware_model', String(model.id), {
            model_key: model.modelKey,
            display_name: model.displayName,
        });
        return this.serializeFirmwareModel(model);
    }
    async listDeviceGroups() {
        const groups = await this.prisma.deviceGroup.findMany({
            include: {
                _count: {
                    select: {
                        members: true,
                    },
                },
            },
            orderBy: [
                { name: 'asc' },
                { id: 'asc' },
            ],
        });
        return groups.map((group) => this.serializeDeviceGroup(group));
    }
    async createDeviceGroup(body, adminUserId) {
        const group = await this.prisma.deviceGroup.create({
            data: {
                name: body.name.trim(),
                description: body.description?.trim() || null,
            },
            include: {
                _count: {
                    select: {
                        members: true,
                    },
                },
            },
        });
        await this.recordAudit(adminUserId, 'device_group.create', 'device_group', String(group.id), {
            name: group.name,
        });
        return this.serializeDeviceGroup(group);
    }
    async addDeviceToGroup(deviceId, groupId, adminUserId) {
        await this.assertDeviceExists(deviceId);
        await this.assertGroupExists(groupId);
        await this.prisma.deviceGroupMember.upsert({
            where: {
                deviceId_groupId: {
                    deviceId,
                    groupId,
                },
            },
            update: {},
            create: {
                deviceId,
                groupId,
            },
        });
        await this.recordAudit(adminUserId, 'device_group.assign', 'device', String(deviceId), {
            group_id: groupId,
        });
        return this.getDeviceById(deviceId);
    }
    async removeDeviceFromGroup(deviceId, groupId, adminUserId) {
        await this.prisma.deviceGroupMember.deleteMany({
            where: {
                deviceId,
                groupId,
            },
        });
        await this.recordAudit(adminUserId, 'device_group.unassign', 'device', String(deviceId), {
            group_id: groupId,
        });
        return this.getDeviceById(deviceId);
    }
    async listDeviceTags() {
        const tags = await this.prisma.deviceTag.findMany({
            include: {
                _count: {
                    select: {
                        members: true,
                    },
                },
            },
            orderBy: [
                { name: 'asc' },
                { id: 'asc' },
            ],
        });
        return tags.map((tag) => this.serializeDeviceTag(tag));
    }
    async createDeviceTag(body, adminUserId) {
        const tag = await this.prisma.deviceTag.create({
            data: {
                name: body.name.trim(),
                description: body.description?.trim() || null,
                color: body.color?.trim() || null,
            },
            include: {
                _count: {
                    select: {
                        members: true,
                    },
                },
            },
        });
        await this.recordAudit(adminUserId, 'device_tag.create', 'device_tag', String(tag.id), {
            name: tag.name,
        });
        return this.serializeDeviceTag(tag);
    }
    async addTagToDevice(deviceId, tagId, adminUserId) {
        await this.assertDeviceExists(deviceId);
        await this.assertTagExists(tagId);
        await this.prisma.deviceTagMember.upsert({
            where: {
                deviceId_tagId: {
                    deviceId,
                    tagId,
                },
            },
            update: {},
            create: {
                deviceId,
                tagId,
            },
        });
        await this.recordAudit(adminUserId, 'device_tag.assign', 'device', String(deviceId), {
            tag_id: tagId,
        });
        return this.getDeviceById(deviceId);
    }
    async removeTagFromDevice(deviceId, tagId, adminUserId) {
        await this.prisma.deviceTagMember.deleteMany({
            where: {
                deviceId,
                tagId,
            },
        });
        await this.recordAudit(adminUserId, 'device_tag.unassign', 'device', String(deviceId), {
            tag_id: tagId,
        });
        return this.getDeviceById(deviceId);
    }
    async listReleases() {
        const releases = await this.prisma.release.findMany({
            include: {
                files: true,
                firmwareModel: true,
            },
            orderBy: [
                { createdAt: 'desc' },
                { id: 'desc' },
            ],
        });
        return releases.map((release) => this.serializeRelease(release));
    }
    async listCampaignDevices(campaignId) {
        await this.assertCampaignExists(campaignId);
        const states = await this.prisma.campaignDevice.findMany({
            where: {
                campaignId,
            },
            include: {
                device: {
                    include: {
                        firmwareModel: true,
                        groupMemberships: {
                            include: {
                                group: true,
                            },
                        },
                        tagMemberships: {
                            include: {
                                tag: true,
                            },
                        },
                    },
                },
            },
            orderBy: [
                { matchedAt: 'desc' },
                { lastEvaluatedAt: 'desc' },
                { id: 'desc' },
            ],
        });
        return states.map((state) => this.serializeCampaignDevice(state));
    }
    async createRelease(body, adminUserId) {
        const channel = body.channel ?? 'stable';
        const active = body.active ?? true;
        const force = body.force ?? false;
        const rolloutPercent = body.rollout_percent ?? 100;
        const firmwareModel = body.firmware_model_id == null
            ? null
            : await this.prisma.firmwareModel.findUnique({
                where: {
                    id: body.firmware_model_id,
                },
            });
        if (body.firmware_model_id != null && !firmwareModel) {
            throw new common_1.BadRequestException('unknown firmware_model_id');
        }
        const model = (body.model ?? firmwareModel?.modelKey ?? '').trim();
        if (!model) {
            throw new common_1.BadRequestException('model is required when firmware_model_id is not provided');
        }
        if (firmwareModel && model !== firmwareModel.modelKey) {
            throw new common_1.BadRequestException('model does not match firmware_model_id');
        }
        const linkedFirmwareModel = firmwareModel ?? await this.prisma.firmwareModel.findUnique({
            where: {
                modelKey: model,
            },
        });
        const normalizedArtifactPath = this.normalizeArtifactPath(body.artifact_path);
        const filePath = this.resolveArtifactPath(normalizedArtifactPath);
        const [buffer, fileStats] = await Promise.all([(0, promises_1.readFile)(filePath), (0, promises_1.stat)(filePath)]);
        const sha256 = (0, node_crypto_1.createHash)('sha256').update(buffer).digest('hex');
        const downloadUrl = `${this.trimTrailingSlash(env_1.env.FIRMWARE_PUBLIC_BASE_URL)}${normalizedArtifactPath}`;
        const release = await this.prisma.$transaction(async (tx) => {
            await tx.releaseFile.deleteMany({
                where: {
                    release: {
                        model,
                        version: body.version,
                        channel,
                    },
                },
            });
            await tx.release.deleteMany({
                where: {
                    model,
                    version: body.version,
                    channel,
                },
            });
            if (active) {
                await tx.release.updateMany({
                    where: {
                        model,
                        channel,
                        active: true,
                    },
                    data: {
                        active: false,
                    },
                });
            }
            return tx.release.create({
                data: {
                    model,
                    firmwareModelId: linkedFirmwareModel?.id ?? null,
                    version: body.version,
                    versionCode: body.version_code ?? null,
                    downloadUrl,
                    sha256,
                    changelog: body.changelog ?? '',
                    force,
                    rolloutPercent,
                    active,
                    channel,
                    files: {
                        create: [
                            {
                                kind: 'sysupgrade',
                                url: downloadUrl,
                                sha256,
                                sizeBytes: BigInt(fileStats.size),
                            },
                        ],
                    },
                },
                include: {
                    files: true,
                    firmwareModel: true,
                },
            });
        });
        await this.recordAudit(adminUserId, 'release.create', 'release', String(release.id), {
            model,
            version: release.version,
            artifact_path: normalizedArtifactPath,
        });
        return this.serializeRelease(release);
    }
    async listCampaigns(includeArchived = false) {
        const campaigns = await this.prisma.campaign.findMany({
            where: includeArchived
                ? undefined
                : {
                    archivedAt: null,
                },
            include: {
                release: {
                    include: {
                        files: true,
                        firmwareModel: true,
                    },
                },
                targetRules: {
                    include: {
                        group: true,
                        tag: true,
                    },
                },
                _count: {
                    select: {
                        devices: true,
                    },
                },
            },
            orderBy: [
                { active: 'desc' },
                { priority: 'desc' },
                { createdAt: 'desc' },
            ],
        });
        return campaigns.map((campaign) => this.serializeCampaign(campaign));
    }
    async listAuditLogs(limit) {
        const safeLimit = Math.max(1, Math.min(200, limit ?? 50));
        const logs = await this.prisma.auditLog.findMany({
            include: {
                adminUser: true,
            },
            orderBy: [
                { createdAt: 'desc' },
                { id: 'desc' },
            ],
            take: safeLimit,
        });
        return logs.map((log) => this.serializeAuditLog(log));
    }
    async createCampaign(body, adminUserId) {
        const release = await this.prisma.release.findUnique({
            where: {
                id: body.release_id,
            },
        });
        if (!release) {
            throw new common_1.NotFoundException('release not found');
        }
        const campaign = await this.prisma.campaign.create({
            data: {
                releaseId: release.id,
                name: body.name.trim(),
                description: body.description?.trim() || null,
                channel: body.channel?.trim() || release.channel,
                priority: body.priority ?? 100,
                rolloutPercent: body.rollout_percent ?? release.rolloutPercent,
                active: body.active ?? true,
                startAt: body.start_at ? new Date(body.start_at) : null,
                endAt: body.end_at ? new Date(body.end_at) : null,
                targetRules: {
                    create: (body.rules ?? []).map((rule) => ({
                        ruleType: rule.rule_type.trim(),
                        operator: rule.operator?.trim() || 'eq',
                        valueString: rule.value_string?.trim() || null,
                        valueJson: rule.value_json == null ? client_1.Prisma.JsonNull : rule.value_json,
                        isExclude: rule.is_exclude ?? false,
                        groupId: rule.group_id ?? null,
                        tagId: rule.tag_id ?? null,
                    })),
                },
            },
            include: {
                release: {
                    include: {
                        files: true,
                        firmwareModel: true,
                    },
                },
                targetRules: {
                    include: {
                        group: true,
                        tag: true,
                    },
                },
                _count: {
                    select: {
                        devices: true,
                    },
                },
            },
        });
        await this.recordAudit(adminUserId, 'campaign.create', 'campaign', String(campaign.id), {
            release_id: release.id,
            name: campaign.name,
            active: campaign.active,
        });
        return this.serializeCampaign(campaign);
    }
    async updateCampaign(campaignId, body, adminUserId) {
        const currentCampaign = await this.prisma.campaign.findUnique({
            where: {
                id: campaignId,
            },
            include: {
                release: true,
                targetRules: true,
            },
        });
        if (!currentCampaign) {
            throw new common_1.NotFoundException('campaign not found');
        }
        if (currentCampaign.archivedAt) {
            throw new common_1.BadRequestException('archived campaigns cannot be edited');
        }
        const release = await this.prisma.release.findUnique({
            where: {
                id: body.release_id ?? currentCampaign.releaseId,
            },
        });
        if (!release) {
            throw new common_1.NotFoundException('release not found');
        }
        const nextChannel = body.channel === undefined
            ? currentCampaign.channel
            : body.channel.trim() || release.channel;
        const nextRolloutPercent = body.rollout_percent ?? currentCampaign.rolloutPercent;
        const nextStartAt = body.start_at === undefined
            ? currentCampaign.startAt
            : (body.start_at ? new Date(body.start_at) : null);
        const nextEndAt = body.end_at === undefined
            ? currentCampaign.endAt
            : (body.end_at ? new Date(body.end_at) : null);
        const shouldResetDeviceStates = (body.release_id ?? currentCampaign.releaseId) !== currentCampaign.releaseId
            || nextChannel !== currentCampaign.channel
            || nextRolloutPercent !== currentCampaign.rolloutPercent
            || !this.sameDateTime(nextStartAt, currentCampaign.startAt)
            || !this.sameDateTime(nextEndAt, currentCampaign.endAt)
            || body.rules !== undefined;
        const campaign = await this.prisma.$transaction(async (tx) => {
            await tx.campaign.update({
                where: {
                    id: campaignId,
                },
                data: {
                    releaseId: body.release_id ?? currentCampaign.releaseId,
                    name: body.name === undefined ? undefined : body.name.trim(),
                    description: body.description === undefined ? undefined : (body.description.trim() || null),
                    channel: nextChannel,
                    priority: body.priority ?? currentCampaign.priority,
                    rolloutPercent: nextRolloutPercent,
                    active: body.active ?? currentCampaign.active,
                    startAt: nextStartAt,
                    endAt: nextEndAt,
                    targetRules: body.rules === undefined
                        ? undefined
                        : {
                            deleteMany: {},
                            create: body.rules.map((rule) => ({
                                ruleType: rule.rule_type.trim(),
                                operator: rule.operator?.trim() || 'eq',
                                valueString: rule.value_string?.trim() || null,
                                valueJson: rule.value_json == null ? client_1.Prisma.JsonNull : rule.value_json,
                                isExclude: rule.is_exclude ?? false,
                                groupId: rule.group_id ?? null,
                                tagId: rule.tag_id ?? null,
                            })),
                        },
                },
            });
            if (shouldResetDeviceStates) {
                await tx.campaignDevice.deleteMany({
                    where: {
                        campaignId,
                    },
                });
            }
            return tx.campaign.findUniqueOrThrow({
                where: {
                    id: campaignId,
                },
                include: {
                    release: {
                        include: {
                            files: true,
                            firmwareModel: true,
                        },
                    },
                    targetRules: {
                        include: {
                            group: true,
                            tag: true,
                        },
                    },
                    _count: {
                        select: {
                            devices: true,
                        },
                    },
                },
            });
        });
        await this.recordAudit(adminUserId, 'campaign.update', 'campaign', String(campaign.id), {
            release_id: campaign.release.id,
            name: campaign.name,
            active: campaign.active,
            device_states_reset: shouldResetDeviceStates,
        });
        return this.serializeCampaign(campaign);
    }
    async setCampaignActive(campaignId, active, adminUserId) {
        const existingCampaign = await this.prisma.campaign.findUnique({
            where: {
                id: campaignId,
            },
            select: {
                archivedAt: true,
            },
        });
        if (!existingCampaign) {
            throw new common_1.NotFoundException('campaign not found');
        }
        if (existingCampaign.archivedAt && active) {
            throw new common_1.BadRequestException('archived campaigns cannot be activated');
        }
        const campaign = await this.prisma.campaign.update({
            where: {
                id: campaignId,
            },
            data: {
                active,
            },
            include: {
                release: {
                    include: {
                        files: true,
                        firmwareModel: true,
                    },
                },
                targetRules: {
                    include: {
                        group: true,
                        tag: true,
                    },
                },
                _count: {
                    select: {
                        devices: true,
                    },
                },
            },
        });
        await this.recordAudit(adminUserId, active ? 'campaign.activate' : 'campaign.pause', 'campaign', String(campaign.id), {
            active,
            name: campaign.name,
        });
        return this.serializeCampaign(campaign);
    }
    async archiveCampaign(campaignId, adminUserId) {
        const existingCampaign = await this.prisma.campaign.findUnique({
            where: {
                id: campaignId,
            },
            select: {
                id: true,
                name: true,
                archivedAt: true,
            },
        });
        if (!existingCampaign) {
            throw new common_1.NotFoundException('campaign not found');
        }
        const campaign = await this.prisma.campaign.update({
            where: {
                id: campaignId,
            },
            data: {
                active: false,
                archivedAt: existingCampaign.archivedAt ?? new Date(),
            },
            include: {
                release: {
                    include: {
                        files: true,
                        firmwareModel: true,
                    },
                },
                targetRules: {
                    include: {
                        group: true,
                        tag: true,
                    },
                },
                _count: {
                    select: {
                        devices: true,
                    },
                },
            },
        });
        await this.recordAudit(adminUserId, 'campaign.archive', 'campaign', String(campaign.id), {
            name: campaign.name,
            archived_at: campaign.archivedAt?.toISOString() ?? null,
        });
        return this.serializeCampaign(campaign);
    }
    async deleteCampaign(campaignId, adminUserId) {
        const existingCampaign = await this.prisma.campaign.findUnique({
            where: {
                id: campaignId,
            },
            select: {
                id: true,
                name: true,
            },
        });
        if (!existingCampaign) {
            throw new common_1.NotFoundException('campaign not found');
        }
        await this.recordAudit(adminUserId, 'campaign.delete', 'campaign', String(existingCampaign.id), {
            name: existingCampaign.name,
        });
        await this.prisma.campaign.delete({
            where: {
                id: campaignId,
            },
        });
        return {
            ok: true,
            deleted_id: campaignId,
        };
    }
    normalizeArtifactPath(artifactPath) {
        const normalized = node_path_1.default.posix.normalize(artifactPath);
        if (!normalized.startsWith('/firmware/')) {
            throw new common_1.BadRequestException('artifact_path must start with /firmware/');
        }
        return normalized;
    }
    resolveArtifactPath(artifactPath) {
        const firmwareRoot = node_path_1.default.resolve(process.cwd(), 'public', 'firmware');
        const resolvedPath = node_path_1.default.resolve(process.cwd(), 'public', `.${artifactPath}`);
        if (resolvedPath !== firmwareRoot && !resolvedPath.startsWith(`${firmwareRoot}${node_path_1.default.sep}`)) {
            throw new common_1.BadRequestException('artifact_path resolves outside public/firmware');
        }
        return resolvedPath;
    }
    serializeRelease(release) {
        return {
            id: release.id,
            model: release.model,
            firmware_model: release.firmwareModel
                ? {
                    id: release.firmwareModel.id,
                    slug: release.firmwareModel.slug,
                    model_key: release.firmwareModel.modelKey,
                    display_name: release.firmwareModel.displayName,
                }
                : null,
            version: release.version,
            version_code: release.versionCode,
            download_url: release.downloadUrl,
            sha256: release.sha256,
            changelog: release.changelog ?? '',
            force: release.force,
            rollout_percent: release.rolloutPercent,
            active: release.active,
            channel: release.channel,
            created_at: release.createdAt.toISOString(),
            updated_at: release.updatedAt.toISOString(),
            files: release.files.map((file) => ({
                id: file.id,
                kind: file.kind,
                url: file.url,
                sha256: file.sha256,
                size_bytes: file.sizeBytes === null ? null : Number(file.sizeBytes),
                created_at: file.createdAt.toISOString(),
            })),
        };
    }
    serializeFirmwareModel(model) {
        return {
            id: model.id,
            slug: model.slug,
            model_key: model.modelKey,
            display_name: model.displayName,
            board_identifier: model.boardIdentifier,
            artifact_kind: model.artifactKind,
            notes: model.notes,
            active: model.active,
            created_at: model.createdAt.toISOString(),
            updated_at: model.updatedAt.toISOString(),
            device_count: model._count.devices,
            release_count: model._count.releases,
        };
    }
    serializeDevice(device) {
        return {
            id: device.id,
            token: device.token,
            model: device.model,
            board: device.board,
            mac: device.mac,
            firmware_model: device.firmwareModel
                ? {
                    id: device.firmwareModel.id,
                    slug: device.firmwareModel.slug,
                    display_name: device.firmwareModel.displayName,
                    model_key: device.firmwareModel.modelKey,
                }
                : null,
            current_version: device.currentVersion,
            status: device.status,
            last_result: device.lastResult,
            last_error: device.lastError,
            last_ip: device.lastIp,
            first_registered_at: device.firstRegisteredAt?.toISOString() ?? null,
            last_seen_at: device.lastSeenAt?.toISOString() ?? null,
            created_at: device.createdAt.toISOString(),
            updated_at: device.updatedAt.toISOString(),
            groups: device.groupMemberships.map((membership) => ({
                id: membership.group.id,
                name: membership.group.name,
            })),
            tags: device.tagMemberships.map((membership) => ({
                id: membership.tag.id,
                name: membership.tag.name,
                color: membership.tag.color,
            })),
        };
    }
    serializeDeviceGroup(group) {
        return {
            id: group.id,
            name: group.name,
            description: group.description,
            created_at: group.createdAt.toISOString(),
            updated_at: group.updatedAt.toISOString(),
            member_count: group._count.members,
        };
    }
    serializeDeviceTag(tag) {
        return {
            id: tag.id,
            name: tag.name,
            description: tag.description,
            color: tag.color,
            created_at: tag.createdAt.toISOString(),
            updated_at: tag.updatedAt.toISOString(),
            member_count: tag._count.members,
        };
    }
    serializeCampaign(campaign) {
        return {
            id: campaign.id,
            name: campaign.name,
            description: campaign.description,
            channel: campaign.channel,
            priority: campaign.priority,
            rollout_percent: campaign.rolloutPercent,
            active: campaign.active,
            archived_at: campaign.archivedAt?.toISOString() ?? null,
            start_at: campaign.startAt?.toISOString() ?? null,
            end_at: campaign.endAt?.toISOString() ?? null,
            created_at: campaign.createdAt.toISOString(),
            updated_at: campaign.updatedAt.toISOString(),
            device_state_count: campaign._count.devices,
            release: this.serializeRelease(campaign.release),
            rules: campaign.targetRules.map((rule) => ({
                id: rule.id,
                rule_type: rule.ruleType,
                operator: rule.operator,
                value_string: rule.valueString,
                value_json: rule.valueJson,
                is_exclude: rule.isExclude,
                group: rule.group
                    ? {
                        id: rule.group.id,
                        name: rule.group.name,
                    }
                    : null,
                tag: rule.tag
                    ? {
                        id: rule.tag.id,
                        name: rule.tag.name,
                        color: rule.tag.color,
                    }
                    : null,
            })),
        };
    }
    serializeCampaignDevice(state) {
        return {
            id: state.id,
            eligibility_status: state.eligibilityStatus,
            update_status: state.updateStatus,
            last_evaluated_at: state.lastEvaluatedAt?.toISOString() ?? null,
            matched_at: state.matchedAt?.toISOString() ?? null,
            delivered_at: state.deliveredAt?.toISOString() ?? null,
            created_at: state.createdAt.toISOString(),
            updated_at: state.updatedAt.toISOString(),
            device: this.serializeDevice(state.device),
        };
    }
    serializeAuditLog(log) {
        return {
            id: log.id,
            action: log.action,
            entity_type: log.entityType,
            entity_id: log.entityId,
            payload_json: log.payloadJson,
            created_at: log.createdAt.toISOString(),
            admin_user: log.adminUser
                ? {
                    id: log.adminUser.id,
                    email: log.adminUser.email,
                    role: log.adminUser.role,
                }
                : null,
        };
    }
    async getDeviceById(deviceId) {
        const device = await this.prisma.device.findUnique({
            where: {
                id: deviceId,
            },
            include: {
                firmwareModel: true,
                groupMemberships: {
                    include: {
                        group: true,
                    },
                },
                tagMemberships: {
                    include: {
                        tag: true,
                    },
                },
            },
        });
        if (!device) {
            throw new common_1.NotFoundException('device not found');
        }
        return this.serializeDevice(device);
    }
    async assertDeviceExists(deviceId) {
        const device = await this.prisma.device.findUnique({
            where: {
                id: deviceId,
            },
            select: {
                id: true,
            },
        });
        if (!device) {
            throw new common_1.NotFoundException('device not found');
        }
    }
    async assertGroupExists(groupId) {
        const group = await this.prisma.deviceGroup.findUnique({
            where: {
                id: groupId,
            },
            select: {
                id: true,
            },
        });
        if (!group) {
            throw new common_1.NotFoundException('group not found');
        }
    }
    async assertTagExists(tagId) {
        const tag = await this.prisma.deviceTag.findUnique({
            where: {
                id: tagId,
            },
            select: {
                id: true,
            },
        });
        if (!tag) {
            throw new common_1.NotFoundException('tag not found');
        }
    }
    async assertCampaignExists(campaignId) {
        const campaign = await this.prisma.campaign.findUnique({
            where: {
                id: campaignId,
            },
            select: {
                id: true,
            },
        });
        if (!campaign) {
            throw new common_1.NotFoundException('campaign not found');
        }
    }
    async recordAudit(adminUserId, action, entityType, entityId, payload) {
        await this.prisma.auditLog.create({
            data: {
                adminUserId: adminUserId ?? null,
                action,
                entityType,
                entityId,
                payloadJson: payload,
            },
        });
    }
    normalizeSlug(value) {
        const slug = value
            .trim()
            .toLowerCase()
            .replace(/[^a-z0-9]+/g, '-')
            .replace(/^-+|-+$/g, '');
        if (!slug) {
            throw new common_1.BadRequestException('unable to derive a valid slug');
        }
        return slug;
    }
    sameDateTime(left, right) {
        if (left === null || right === null) {
            return left === right;
        }
        return left.getTime() === right.getTime();
    }
    trimTrailingSlash(value) {
        return value.endsWith('/') ? value.slice(0, -1) : value;
    }
};
exports.AdminService = AdminService;
exports.AdminService = AdminService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], AdminService);
//# sourceMappingURL=admin.service.js.map