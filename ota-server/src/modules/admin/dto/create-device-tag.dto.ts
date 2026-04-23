import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateDeviceTagDto {
  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsString()
  @IsOptional()
  color?: string;
}