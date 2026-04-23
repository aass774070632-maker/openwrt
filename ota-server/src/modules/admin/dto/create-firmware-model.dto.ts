import { Transform } from 'class-transformer';
import { IsBoolean, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateFirmwareModelDto {
  @IsString()
  @IsOptional()
  slug?: string;

  @IsString()
  @IsNotEmpty()
  model_key!: string;

  @IsString()
  @IsNotEmpty()
  display_name!: string;

  @IsString()
  @IsOptional()
  board_identifier?: string;

  @IsString()
  @IsOptional()
  artifact_kind?: string;

  @IsString()
  @IsOptional()
  notes?: string;

  @Transform(({ value }) => value ?? true)
  @IsBoolean()
  @IsOptional()
  active?: boolean;
}