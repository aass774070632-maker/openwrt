import { Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
  IsInt,
  IsISO8601,
  IsNotEmpty,
  IsOptional,
  IsString,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';
import { CreateCampaignRuleDto } from './create-campaign.dto';

export class UpdateCampaignDto {
  @Type(() => Number)
  @IsInt()
  @IsOptional()
  release_id?: number;

  @IsString()
  @IsNotEmpty()
  @IsOptional()
  name?: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsString()
  @IsOptional()
  channel?: string;

  @Type(() => Number)
  @IsInt()
  @IsOptional()
  priority?: number;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  @IsOptional()
  rollout_percent?: number;

  @IsBoolean()
  @IsOptional()
  active?: boolean;

  @IsISO8601()
  @IsOptional()
  start_at?: string;

  @IsISO8601()
  @IsOptional()
  end_at?: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateCampaignRuleDto)
  @IsOptional()
  rules?: CreateCampaignRuleDto[];
}