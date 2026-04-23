import { CreateCampaignRuleDto } from './create-campaign.dto';
export declare class UpdateCampaignDto {
    release_id?: number;
    name?: string;
    description?: string;
    channel?: string;
    priority?: number;
    rollout_percent?: number;
    active?: boolean;
    start_at?: string;
    end_at?: string;
    rules?: CreateCampaignRuleDto[];
}
