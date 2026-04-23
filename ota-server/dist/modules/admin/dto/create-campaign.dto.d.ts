export declare class CreateCampaignRuleDto {
    rule_type: string;
    operator?: string;
    value_string?: string;
    value_json?: unknown;
    is_exclude?: boolean;
    group_id?: number;
    tag_id?: number;
}
export declare class CreateCampaignDto {
    release_id: number;
    name: string;
    description?: string;
    channel?: string;
    priority?: number;
    rollout_percent?: number;
    active?: boolean;
    start_at?: string;
    end_at?: string;
    rules?: CreateCampaignRuleDto[];
}
