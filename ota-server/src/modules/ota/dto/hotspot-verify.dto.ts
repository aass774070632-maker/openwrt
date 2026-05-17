import { IsOptional, IsString } from 'class-validator';

export class HotspotVerifyDto {
  @IsString()
  token!: string;

  @IsString()
  @IsOptional()
  model?: string;

  @IsString()
  @IsOptional()
  mac?: string;
}
