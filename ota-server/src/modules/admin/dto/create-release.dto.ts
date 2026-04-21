import { Transform } from 'class-transformer';
import { IsBoolean, IsInt, IsNotEmpty, IsOptional, IsString, Max, Min } from 'class-validator';

export class CreateReleaseDto {
  @IsString()
  @IsNotEmpty()
  model!: string;

  @IsString()
  @IsNotEmpty()
  version!: string;

  @IsString()
  @IsOptional()
  version_code?: string;

  @IsString()
  @IsNotEmpty()
  artifact_path!: string;

  @IsString()
  @IsOptional()
  changelog?: string;

  @Transform(({ value }) => value ?? false)
  @IsBoolean()
  @IsOptional()
  force?: boolean;

  @Transform(({ value }) => value ?? 100)
  @IsInt()
  @Min(1)
  @Max(100)
  @IsOptional()
  rollout_percent?: number;

  @Transform(({ value }) => value ?? true)
  @IsBoolean()
  @IsOptional()
  active?: boolean;

  @Transform(({ value }) => value ?? 'stable')
  @IsString()
  @IsNotEmpty()
  @IsOptional()
  channel?: string;
}