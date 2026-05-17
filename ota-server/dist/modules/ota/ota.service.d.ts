import { HeartbeatDto } from './dto/heartbeat.dto';
import { HotspotVerifyDto } from './dto/hotspot-verify.dto';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { UpdateQueryDto } from './dto/update-query.dto';
import { PrismaService } from '../prisma/prisma.service';
type OtaRequestMeta = {
    ipAddress: string | null;
    signature: string | null;
    timestamp: string | null;
};
export declare class OtaService {
    private readonly prisma;
    private readonly rateBuckets;
    constructor(prisma: PrismaService);
    register(body: RegisterDeviceDto, meta: OtaRequestMeta): Promise<{
        accepted: boolean;
        device_id: number;
    }>;
    checkUpdate(query: UpdateQueryDto, meta: OtaRequestMeta): Promise<{
        update_available: boolean;
        version: string;
        download_url: string;
        download_urls: string[];
        size_bytes: number | null;
        sha256: string;
        changelog: string;
        force: boolean;
        rollout_percent: number;
        campaign: {
            id: number;
            name: string;
            priority: number;
        };
    } | {
        update_available: boolean;
        version?: undefined;
        download_url?: undefined;
        download_urls?: undefined;
        size_bytes?: undefined;
        sha256?: undefined;
        changelog?: undefined;
        force?: undefined;
        rollout_percent?: undefined;
    } | {
        update_available: boolean;
        version: string;
        download_url: string;
        download_urls: string[];
        size_bytes: number | null;
        sha256: string;
        changelog: string;
        force: boolean;
        rollout_percent: number;
    }>;
    heartbeat(body: HeartbeatDto, meta: OtaRequestMeta): Promise<{
        ok: boolean;
    }>;
    hotspotVerify(body: HotspotVerifyDto, meta: OtaRequestMeta): Promise<{
        accepted: boolean;
        reason: string;
        expires_in?: undefined;
    } | {
        accepted: boolean;
        expires_in: number;
        reason?: undefined;
    }>;
    private collectDownloadUrls;
    private buildCampaignUpdateResponse;
    private findMatchingCampaign;
    private matchesCampaignRules;
    private matchesTargetRule;
    private compareStringValue;
    private isRolloutEligible;
    private recordCampaignState;
    private resolveFirmwareModelId;
    private markDeliveredCampaigns;
    private updateLatestCampaignState;
    private recordEvent;
    private toJsonObject;
    private enforceRateLimit;
    private verifySignature;
}
export {};
