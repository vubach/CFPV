export class NutritionInfoDto {
  calories?: number;
  sugarGrams?: number;
  fatGrams?: number;
  proteinGrams?: number;
  caffeineMg?: number;
  ingredients?: string[];

  constructor(partial: Partial<NutritionInfoDto>) {
    Object.assign(this, partial);
  }
}

export class ProductVariantDto {
  id: string;
  name: string;
  sizeMl?: number;
  priceModifier: number;
  isDefault: boolean;
  sortOrder: number;

  constructor(partial: Partial<ProductVariantDto>) {
    Object.assign(this, partial);
  }
}

export class ProductResponseDto {
  id: string;
  categoryId: string;
  name: string;
  slug: string;
  description?: string;
  price: number;
  imageUrl?: string;
  isAvailable: boolean;
  isFeatured: boolean;
  sortOrder: number;
  createdAt: Date;
  variants: ProductVariantDto[];
  nutrition?: NutritionInfoDto;

  constructor(partial: Partial<ProductResponseDto>) {
    Object.assign(this, partial);
    if (partial.variants) {
      this.variants = partial.variants.map((v) => new ProductVariantDto(v));
    }
  }
}
