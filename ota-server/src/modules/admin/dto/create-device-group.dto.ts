import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateDeviceGroupDto {
  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsString()
  @IsOptional()
  description?: string;
}