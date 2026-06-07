import { IsOptional, IsString, IsUUID } from 'class-validator';

export class UpdateCartStoreDto {
  @IsOptional()
  @IsUUID()
  storeId?: string;

  @IsOptional()
  @IsString()
  storeName?: string;
}
