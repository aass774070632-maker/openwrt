import { AuthenticatedAdmin } from '../auth/auth.service';
import { CreateCampaignDto } from './dto/create-campaign.dto';
import { CreateDeviceGroupDto } from './dto/create-device-group.dto';
import { CreateDeviceTagDto } from './dto/create-device-tag.dto';
import { CreateFirmwareModelDto } from './dto/create-firmware-model.dto';
import { CreateReleaseDto } from './dto/create-release.dto';
import { UpdateCampaignDto } from './dto/update-campaign.dto';
import { AdminService } from './admin.service';
type AdminRequestLike = {
    admin?: AuthenticatedAdmin;
};
export declare class AdminController {
    private readonly adminService;
    constructor(adminService: AdminService);
    dashboard(): Promise<{
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
    listModels(): Promise<{
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
    createModel(body: CreateFirmwareModelDto, request: AdminRequestLike): Promise<{
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
    listGroups(): Promise<{
        id: number;
        name: string;
        description: string | null;
        created_at: string;
        updated_at: string;
        member_count: number;
    }[]>;
    createGroup(body: CreateDeviceGroupDto, request: AdminRequestLike): Promise<{
        id: number;
        name: string;
        description: string | null;
        created_at: string;
        updated_at: string;
        member_count: number;
    }>;
    addDeviceToGroup(deviceId: number, groupId: number, request: AdminRequestLike): Promise<{
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
    removeDeviceFromGroup(deviceId: number, groupId: number, request: AdminRequestLike): Promise<{
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
    listTags(): Promise<{
        id: number;
        name: string;
        description: string | null;
        color: string | null;
        created_at: string;
        updated_at: string;
        member_count: number;
    }[]>;
    createTag(body: CreateDeviceTagDto, request: AdminRequestLike): Promise<{
        id: number;
        name: string;
        description: string | null;
        color: string | null;
        created_at: string;
        updated_at: string;
        member_count: number;
    }>;
    addTagToDevice(deviceId: number, tagId: number, request: AdminRequestLike): Promise<{
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
    removeTagFromDevice(deviceId: number, tagId: number, request: AdminRequestLike): Promise<{
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
    createRelease(body: CreateReleaseDto, request: AdminRequestLike): Promise<{
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
    createReleaseWithUpload(artifact: {
        filename?: string;
    } | undefined, body: Record<string, string | undefined>, request: AdminRequestLike): Promise<{
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
    listCampaigns(includeArchived?: string): Promise<{
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
            value_json: import("@prisma/client/runtime/library").JsonValue;
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
    listAuditLogs(limit?: string): Promise<{
        id: number;
        action: string;
        entity_type: string;
        entity_id: string | null;
        payload_json: import("@prisma/client/runtime/library").JsonValue;
        created_at: string;
        admin_user: {
            id: number;
            email: string;
            role: string;
        } | null;
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
    createCampaign(body: CreateCampaignDto, request: AdminRequestLike): Promise<{
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
            value_json: import("@prisma/client/runtime/library").JsonValue;
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
    updateCampaign(campaignId: number, body: UpdateCampaignDto, request: AdminRequestLike): Promise<{
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
            value_json: import("@prisma/client/runtime/library").JsonValue;
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
    archiveCampaign(campaignId: number, request: AdminRequestLike): Promise<{
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
            value_json: import("@prisma/client/runtime/library").JsonValue;
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
    deleteCampaign(campaignId: number, request: AdminRequestLike): Promise<{
        ok: boolean;
        deleted_id: number;
    }>;
    activateCampaign(campaignId: number, request: AdminRequestLike): Promise<{
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
            value_json: import("@prisma/client/runtime/library").JsonValue;
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
    pauseCampaign(campaignId: number, request: AdminRequestLike): Promise<{
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
            value_json: import("@prisma/client/runtime/library").JsonValue;
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
}
export {};
