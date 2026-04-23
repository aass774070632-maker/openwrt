import { Transform, Type } from 'class-transformer';
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

export class CreateCampaignRuleDto {
  @IsString()
  @IsNotEmpty()
  rule_type!: string;

  @IsString()
  @IsOptional()
  operator?: string;

  @IsString()
  @IsOptional()
  value_string?: string;

  @IsOptional()
  value_json?: unknown;

  @Transform(({ value }) => value ?? false)
  @IsBoolean()
  @IsOptional()
  is_exclude?: boolean;

  @Type(() => Number)
  @IsInt()
  @IsOptional()
  group_id?: number;

  @Type(() => Number)
  @IsInt()
  @IsOptional()
  tag_id?: number;
}

export class CreateCampaignDto {
  @Type(() => Number)
  @IsInt()
  release_id!: number;

  @IsString()
  @IsNotEmpty()
  name!: string;

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

  @Transform(({ value }) => value ?? true)
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