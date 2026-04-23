export declare class CreateReleaseDto {
    model?: string;
    firmware_model_id?: number;
    version: string;
    version_code?: string;
    artifact_path: string;
    changelog?: string;
    force?: boolean;
    rollout_percent?: number;
    active?: boolean;
    channel?: string;
}
