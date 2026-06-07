import { IsOptional, IsString, MaxLength } from 'class-validator';

export class UpdateCartNotesDto {
  @IsOptional()
  @IsString()
  @MaxLength(500)
  notes?: string;
}
