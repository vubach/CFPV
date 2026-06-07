import { IsString, Length } from 'class-validator';

export class ForgotPasswordDto {
  @IsString()
  @Length(10, 20)
  phone: string;
}
