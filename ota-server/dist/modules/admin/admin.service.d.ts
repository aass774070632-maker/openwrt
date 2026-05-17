import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateCampaignDto } from './dto/create-campaign.dto';
import { CreateDeviceGroupDto } from './dto/create-device-group.dto';
import { CreateDeviceTagDto } from './dto/create-device-tag.dto';
import { CreateFirmwareModelDto } from './dto/create-firmware-model.dto';
import { CreateReleaseDto } from './dto/create-release.dto';
import { UpdateCampaignDto } from './dto/update-campaign.dto';
export declare class AdminService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    getDashboardSummary(): Promise<{
        counts: {
            total_devices: number;
            online_last_24h: number;
            active_campaigns: number;
            firmware_models: number;
            releases: number;
        };
        versions: {
            version: string;
            count: number;
        }[];
        models: {
            model: string;
            count: number;
        }[];
        recent_errors: {
            id: number;
            model: string;
            mac: string;
            last_error: string | null;
            last_seen_at: string | null;
        }[];
    }>;
    listDevices(): Promise<{
        id: number;
        token: string;
        model: string;
        board: string;
        mac: string;
        firmware_model: {
            id: number;
            slug: string;
            display_name: string;
            model_key: string;
        } | null;
        current_version: string | null;
        status: string | null;
        last_result: string | null;
        last_error: string | null;
        last_ip: string | null;
        first_registered_at: string | null;
        last_seen_at: string | null;
        created_at: string;
        updated_at: string;
        groups: {
            id: number;
            name: string;
        }[];
        tags: {
            id: number;
            name: string;
            color: string | null;
        }[];
    }[]>;
    toggleDeviceHotspot(deviceId: number, adminId?: number): Promise<{
        id: number;
        token: string;
        model: string;
        board: string;
        mac: string;
        firmware_model: {
            id: number;
            slug: string;
            display_name: string;
            model_key: string;
        } | null;
        current_version: string | null;
        status: string | null;
        last_result: string | null;
        last_error: string | null;
        last_ip: string | null;
        first_registered_at: string | null;
        last_seen_at: string | null;
        created_at: string;
        updated_at: string;
        groups: {
            id: number;
            name: string;
        }[];
        tags: {
            id: number;
            name: string;
            color: string | null;
        }[];
    }>;
    listFirmwareModels(): Promise<{
        id: number;
        slug: string;
        model_key: string;
        display_name: string;
        board_identifier: string | null;
        artifact_kind: string;
        notes: string | null;
        active: boolean;
        created_at: string;
        updated_at: string;
        device_count: number;
        release_count: number;
    }[]>;
    createFirmwareModel(body: CreateFirmwareModelDto, adminUserId?: number): Promise<{
        id: number;
        slug: string;
        model_key: string;
        display_name: string;
        board_identifier: string | null;
        artifact_kind: string;
        notes: string | null;
        active: boolean;
        created_at: string;
        updated_at: string;
        device_count: number;
        release_count: number;
    }>;
    listDeviceGroups(): Promise<{
        id: number;
        name: string;
        description: string | null;
        created_at: string;
        updated_at: string;
        member_count: number;
    }[]>;
    createDeviceGroup(body: CreateDeviceGroupDto, adminUserId?: number): Promise<{
        id: number;
        name: string;
        description: string | null;
        created_at: string;
        updated_at: string;
        member_count: number;
    }>;
    addDeviceToGroup(deviceId: number, groupId: number, adminUserId?: number): Promise<{
        id: number;
        token: string;
        model: string;
        board: string;
        mac: string;
        firmware_model: {
            id: number;
            slug: string;
            display_name: string;
            model_key: string;
        } | null;
        current_version: string | null;
        status: string | null;
        last_result: string | null;
        last_error: string | null;
        last_ip: string | null;
        first_registered_at: string | null;
        last_seen_at: string | null;
        created_at: string;
        updated_at: string;
        groups: {
            id: number;
            name: string;
        }[];
        tags: {
            id: number;
            name: string;
            color: string | null;
        }[];
    }>;
    removeDeviceFromGroup(deviceId: number, groupId: number, adminUserId?: number): Promise<{
        id: number;
        token: string;
        model: string;
        board: string;
        mac: string;
        firmware_model: {
            id: number;
            slug: string;
            display_name: string;
            model_key: string;
        } | null;
        current_version: string | null;
        status: string | null;
        last_result: string | null;
        last_error: string | null;
        last_ip: string | null;
        first_registered_at: string | null;
        last_seen_at: string | null;
        created_at: string;
        updated_at: string;
        groups: {
            id: number;
            name: string;
        }[];
        tags: {
            id: number;
            name: string;
            color: string | null;
        }[];
    }>;
    listDeviceTags(): Promise<{
        id: number;
        name: string;
        description: string | null;
        color: string | null;
        created_at: string;
        updated_at: string;
        member_count: number;
    }[]>;
    createDeviceTag(body: CreateDeviceTagDto, adminUserId?: number): Promise<{
        id: number;
        name: string;
        description: string | null;
        color: string | null;
        created_at: string;
        updated_at: string;
        member_count: number;
    }>;
    addTagToDevice(deviceId: number, tagId: number, adminUserId?: number): Promise<{
        id: number;
        token: string;
        model: string;
        board: string;
        mac: string;
        firmware_model: {
            id: number;
            slug: string;
            display_name: string;
            model_key: string;
        } | null;
        current_version: string | null;
        status: string | null;
        last_result: string | null;
        last_error: string | null;
        last_ip: string | null;
        first_registered_at: string | null;
        last_seen_at: string | null;
        created_at: string;
        updated_at: string;
        groups: {
            id: number;
            name: string;
        }[];
        tags: {
            id: number;
            name: string;
            color: string | null;
        }[];
    }>;
    removeTagFromDevice(deviceId: number, tagId: number, adminUserId?: number): Promise<{
        id: number;
        token: string;
        model: string;
        board: string;
        mac: string;
        firmware_model: {
            id: number;
            slug: string;
            display_name: string;
            model_key: string;
        } | null;
        current_version: string | null;
        status: string | null;
        last_result: string | null;
        last_error: string | null;
        last_ip: string | null;
        first_registered_at: string | null;
        last_seen_at: string | null;
        created_at: string;
        updated_at: string;
        groups: {
            id: number;
            name: string;
        }[];
        tags: {
            id: number;
            name: string;
            color: string | null;
        }[];
    }>;
    listReleases(): Promise<{
        id: number;
        model: string;
        firmware_model: {
            id: number;
            slug: string;
            model_key: string;
            display_name: string;
        } | null;
        version: string;
        version_code: string | null;
        download_url: string;
        sha256: string;
        changelog: string;
        force: boolean;
        rollout_percent: number;
        active: boolean;
        channel: string;
        created_at: string;
        updated_at: string;
        files: {
            id: number;
            kind: string;
            url: string;
            sha256: string;
            size_bytes: number | null;
            created_at: string;
        }[];
    }[]>;
    listCampaignDevices(campaignId: number): Promise<{
        id: number;
        eligibility_status: string;
        update_status: string | null;
        last_evaluated_at: string | null;
        matched_at: string | null;
        delivered_at: string | null;
        created_at: string;
        updated_at: string;
        device: {
            id: number;
            token: string;
            model: string;
            board: string;
            mac: string;
            firmware_model: {
                id: number;
                slug: string;
                display_name: string;
                model_key: string;
            } | null;
            current_version: string | null;
            status: string | null;
            last_result: string | null;
            last_error: string | null;
            last_ip: string | null;
            first_registered_at: string | null;
            last_seen_at: string | null;
            created_at: string;
            updated_at: string;
            groups: {
                id: number;
                name: string;
            }[];
            tags: {
                id: number;
                name: string;
                color: string | null;
            }[];
        };
    }[]>;
    createRelease(body: CreateReleaseDto, adminUserId?: number): Promise<{
        id: number;
        model: string;
        firmware_model: {
            id: number;
            slug: string;
            model_key: string;
            display_name: string;
        } | null;
        version: string;
        version_code: string | null;
        download_url: string;
        sha256: string;
        changelog: string;
        force: boolean;
        rollout_percent: number;
        active: boolean;
        channel: string;
        created_at: string;
        updated_at: string;
        files: {
            id: number;
            kind: string;
            url: string;
            sha256: string;
            size_bytes: number | null;
            created_at: string;
        }[];
    }>;
    createReleaseFromUpload(body: Record<string, string | undefined>, artifact: {
        filename?: string;
    } | undefined, adminUserId?: number): Promise<{
        id: number;
        model: string;
        firmware_model: {
            id: number;
            slug: string;
            model_key: string;
            display_name: string;
        } | null;
        version: string;
        version_code: string | null;
        download_url: string;
        sha256: string;
        changelog: string;
        force: boolean;
        rollout_percent: number;
        active: boolean;
        channel: string;
        created_at: string;
        updated_at: string;
        files: {
            id: number;
            kind: string;
            url: string;
            sha256: string;
            size_bytes: number | null;
            created_at: string;
        }[];
    }>;
    listCampaigns(includeArchived?: boolean): Promise<{
        id: number;
        name: string;
        description: string | null;
        channel: string;
        priority: number;
        rollout_percent: number;
        active: boolean;
        archived_at: string | null;
        start_at: string | null;
        end_at: string | null;
        created_at: string;
        updated_at: string;
        device_state_count: number;
        release: {
            id: number;
            model: string;
            firmware_model: {
                id: number;
                slug: string;
                model_key: string;
                display_name: string;
            } | null;
            version: string;
            version_code: string | null;
            download_url: string;
            sha256: string;
            changelog: string;
            force: boolean;
            rollout_percent: number;
            active: boolean;
            channel: string;
            created_at: string;
            updated_at: string;
            files: {
                id: number;
                kind: string;
                url: string;
                sha256: string;
                size_bytes: number | null;
                created_at: string;
            }[];
        };
        rules: {
            id: number;
            rule_type: string;
            operator: string;
            value_string: string | null;
            value_json: Prisma.JsonValue;
            is_exclude: boolean;
            group: {
                id: number;
                name: string;
            } | null;
            tag: {
                id: number;
                name: string;
                color: string | null;
            } | null;
        }[];
    }[]>;
    listAuditLogs(limit?: number): Promise<{
        id: number;
        action: string;
        entity_type: string;
        entity_id: string | null;
        payload_json: Prisma.JsonValue;
        created_at: string;
        admin_user: {
            id: number;
            email: string;
            role: string;
        } | null;
    }[]>;
    createCampaign(body: CreateCampaignDto, adminUserId?: number): Promise<{
        id: number;
        name: string;
        description: string | null;
        channel: string;
        priority: number;
        rollout_percent: number;
        active: boolean;
        archived_at: string | null;
        start_at: string | null;
        end_at: string | null;
        created_at: string;
        updated_at: string;
        device_state_count: number;
        release: {
            id: number;
            model: string;
            firmware_model: {
                id: number;
                slug: string;
                model_key: string;
                display_name: string;
            } | null;
            version: string;
            version_code: string | null;
            download_url: string;
            sha256: string;
            changelog: string;
            force: boolean;
            rollout_percent: number;
            active: boolean;
            channel: string;
            created_at: string;
            updated_at: string;
            files: {
                id: number;
                kind: string;
                url: string;
                sha256: string;
                size_bytes: number | null;
                created_at: string;
            }[];
        };
        rules: {
            id: number;
            rule_type: string;
            operator: string;
            value_string: string | null;
            value_json: Prisma.JsonValue;
            is_exclude: boolean;
            group: {
                id: number;
                name: string;
            } | null;
            tag: {
                id: number;
                name: string;
                color: string | null;
            } | null;
        }[];
    }>;
    updateCampaign(campaignId: number, body: UpdateCampaignDto, adminUserId?: number): Promise<{
        id: number;
        name: string;
        description: string | null;
        channel: string;
        priority: number;
        rollout_percent: number;
        active: boolean;
        archived_at: string | null;
        start_at: string | null;
        end_at: string | null;
        created_at: string;
        updated_at: string;
        device_state_count: number;
        release: {
            id: number;
            model: string;
            firmware_model: {
                id: number;
                slug: string;
                model_key: string;
                display_name: string;
            } | null;
            version: string;
            version_code: string | null;
            download_url: string;
            sha256: string;
            changelog: string;
            force: boolean;
            rollout_percent: number;
            active: boolean;
            channel: string;
            created_at: string;
            updated_at: string;
            files: {
                id: number;
                kind: string;
                url: string;
                sha256: string;
                size_bytes: number | null;
                created_at: string;
            }[];
        };
        rules: {
            id: number;
            rule_type: string;
            operator: string;
            value_string: string | null;
            value_json: Prisma.JsonValue;
            is_exclude: boolean;
            group: {
                id: number;
                name: string;
            } | null;
            tag: {
                id: number;
                name: string;
                color: string | null;
            } | null;
        }[];
    }>;
    setCampaignActive(campaignId: number, active: boolean, adminUserId?: number): Promise<{
        id: number;
        name: string;
        description: string | null;
        channel: string;
        priority: number;
        rollout_percent: number;
        active: boolean;
        archived_at: string | null;
        start_at: string | null;
        end_at: string | null;
        created_at: string;
        updated_at: string;
        device_state_count: number;
        release: {
            id: number;
            model: string;
            firmware_model: {
                id: number;
                slug: string;
                model_key: string;
                display_name: string;
            } | null;
            version: string;
            version_code: string | null;
            download_url: string;
            sha256: string;
            changelog: string;
            force: boolean;
            rollout_percent: number;
            active: boolean;
            channel: string;
            created_at: string;
            updated_at: string;
            files: {
                id: number;
                kind: string;
                url: string;
                sha256: string;
                size_bytes: number | null;
                created_at: string;
            }[];
        };
        rules: {
            id: number;
            rule_type: string;
            operator: string;
            value_string: string | null;
            value_json: Prisma.JsonValue;
            is_exclude: boolean;
            group: {
                id: number;
                name: string;
            } | null;
            tag: {
                id: number;
                name: string;
                color: string | null;
            } | null;
        }[];
    }>;
    archiveCampaign(campaignId: number, adminUserId?: number): Promise<{
        id: number;
        name: string;
        description: string | null;
        channel: string;
        priority: number;
        rollout_percent: number;
        active: boolean;
        archived_at: string | null;
        start_at: string | null;
        end_at: string | null;
        created_at: string;
        updated_at: string;
        device_state_count: number;
        release: {
            id: number;
            model: string;
            firmware_model: {
                id: number;
                slug: string;
                model_key: string;
                display_name: string;
            } | null;
            version: string;
            version_code: string | null;
            download_url: string;
            sha256: string;
            changelog: string;
            force: boolean;
            rollout_percent: number;
            active: boolean;
            channel: string;
            created_at: string;
            updated_at: string;
            files: {
                id: number;
                kind: string;
                url: string;
                sha256: string;
                size_bytes: number | null;
                created_at: string;
            }[];
        };
        rules: {
            id: number;
            rule_type: string;
            operator: string;
            value_string: string | null;
            value_json: Prisma.JsonValue;
            is_exclude: boolean;
            group: {
                id: number;
                name: string;
            } | null;
            tag: {
                id: number;
                name: string;
                color: string | null;
            } | null;
        }[];
    }>;
    deleteCampaign(campaignId: number, adminUserId?: number): Promise<{
        ok: boolean;
        deleted_id: number;
    }>;
    private normalizeArtifactPath;
    private resolveArtifactPath;
    private serializeRelease;
    private serializeFirmwareModel;
    private serializeDevice;
    private serializeDeviceGroup;
    private serializeDeviceTag;
    private serializeCampaign;
    private serializeCampaignDevice;
    private serializeAuditLog;
    private getDeviceById;
    private assertDeviceExists;
    private assertGroupExists;
    private assertTagExists;
    private assertCampaignExists;
    private recordAudit;
    private normalizeSlug;
    private cleanOptionalText;
    private requireText;
    private parseOptionalInt;
    private parseOptionalBoolean;
    private sameDateTime;
    private trimTrailingSlash;
}
