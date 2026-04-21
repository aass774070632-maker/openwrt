import { IsNotEmpty, IsString } from 'class-validator';

export class LogoutSessionDto {
  @IsString()
  @IsNotEmpty()
  refresh_token!: string;
}