import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class HeartbeatDto {
  @IsString()
  @IsNotEmpty()
  token!: string;

  @IsString()
  @IsNotEmpty()
  status!: string;

  @IsString()
  @IsOptional()
  current_version?: string;

  @IsString()
  @IsOptional()
  last_result?: string;

  @IsString()
  @IsOptional()
  last_error?: string;
}