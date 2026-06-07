import { IsString, MinLength } from 'class-validator';

export class LoginDto {
  @IsString()
  @MinLength(1)
  login: string;   // phone or email

  @IsString()
  @MinLength(1)
  password: string;
}
