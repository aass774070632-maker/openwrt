import { IsNotEmpty, IsString } from 'class-validator';

export class RefreshSessionDto {
  @IsString()
  @IsNotEmpty()
  refresh_token!: string;
}