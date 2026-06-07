import { IsString, Length } from 'class-validator';

export class VerifyOtpDto {
  @IsString()
  @Length(10, 20)
  phone: string;

  @IsString()
  @Length(6, 6)
  otp: string;
}
