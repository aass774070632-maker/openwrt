import { HeartbeatDto } from './dto/heartbeat.dto';
import { HotspotVerifyDto } from './dto/hotspot-verify.dto';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { UpdateQueryDto } from './dto/update-query.dto';
import { OtaService } from './ota.service';
type OtaRequestLike = {
    ip?: string;
    headers: Record<string, string | string[] | undefined>;
};
export declare class OtaController {
    private readonly otaService;
    constructor(otaService: OtaService);
    register(body: RegisterDeviceDto, request: OtaRequestLike): Promise<{
        accepted: boolean;
        device_id: number;
    }>;
    update(query: UpdateQueryDto, request: OtaRequestLike): Promise<{
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
    heartbeat(body: HeartbeatDto, request: OtaRequestLike): Promise<{
        ok: boolean;
    }>;
    hotspotVerify(body: HotspotVerifyDto, request: OtaRequestLike): Promise<{
        accepted: boolean;
        reason: string;
        expires_in?: undefined;
    } | {
        accepted: boolean;
        expires_in: number;
        reason?: undefined;
    }>;
    private extractMeta;
    private pickHeader;
}
export {};
