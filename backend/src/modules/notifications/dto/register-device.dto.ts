import { IsString, IsIn, IsNotEmpty } from 'class-validator';

export class RegisterDeviceDto {
  @IsString()
  @IsNotEmpty()
  fcmToken: string;

  @IsString()
  @IsIn(['ios', 'android'])
  platform: string;
}
