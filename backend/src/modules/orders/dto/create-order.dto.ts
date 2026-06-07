import { IsOptional, IsString, IsUUID, IsArray } from 'class-validator';

export class CreateOrderDto {
  @IsOptional()
  @IsUUID()
  storeId?: string;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsOptional()
  @IsArray()
  items?: { productId: string; quantity: number; notes?: string }[];
}
