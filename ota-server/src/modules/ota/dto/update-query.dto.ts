import { IsNotEmpty, IsString } from 'class-validator';

export class UpdateQueryDto {
  @IsString()
  @IsNotEmpty()
  token!: string;

  @IsString()
  @IsNotEmpty()
  model!: string;

  @IsString()
  @IsNotEmpty()
  version!: string;

  @IsString()
  @IsNotEmpty()
  mac!: string;

  @IsString()
  @IsNotEmpty()
  board!: string;
}
