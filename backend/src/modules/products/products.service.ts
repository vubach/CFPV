import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Product } from './entities/product.entity';
import { ProductVariant } from './entities/product-variant.entity';
import { ProductResponseDto, ProductVariantDto, NutritionInfoDto } from './dto/product-response.dto';
import { ProductListQueryDto } from './dto/product-list-query.dto';

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product)
    private readonly productRepo: Repository<Product>,
    @InjectRepository(ProductVariant)
    private readonly variantRepo: Repository<ProductVariant>,
  ) {}

  async findAll(query?: ProductListQueryDto): Promise<ProductResponseDto[]> {
    const where: any = { isAvailable: true };

    if (query?.categoryId) {
      where.categoryId = query.categoryId;
    }

    const products = await this.productRepo.find({
      where,
      order: { sortOrder: 'ASC', name: 'ASC' },
      take: query?.limit ?? 50,
      skip: query?.offset ?? 0,
    });

    return products.map((p) => this.toResponse(p));
  }

  async findFeatured(): Promise<ProductResponseDto[]> {
    const products = await this.productRepo.find({
      where: { isFeatured: true, isAvailable: true },
      order: { sortOrder: 'ASC', name: 'ASC' },
      take: 10,
    });

    return products.map((p) => this.toResponse(p));
  }

  async findById(id: string): Promise<ProductResponseDto> {
    const product = await this.productRepo.findOne({
      where: { id },
      relations: ['variants'],
    });

    if (!product) {
      throw new NotFoundException('Product not found');
    }

    return this.toResponse(product, true);
  }

  toResponse(product: Product, includeVariants = false): ProductResponseDto {
    const nutrition =
      product.calories || product.sugar || product.fat || product.protein || product.caffeine || product.ingredients
        ? new NutritionInfoDto({
            calories: product.calories ?? undefined,
            sugarGrams: product.sugar ? Number(product.sugar) : undefined,
            fatGrams: product.fat ? Number(product.fat) : undefined,
            proteinGrams: product.protein ? Number(product.protein) : undefined,
            caffeineMg: product.caffeine ? Number(product.caffeine) : undefined,
            ingredients: product.ingredients ?? undefined,
          })
        : undefined;

    return new ProductResponseDto({
      id: product.id,
      categoryId: product.categoryId,
      name: product.name,
      slug: product.slug,
      description: product.description,
      price: Number(product.price),
      imageUrl: product.imageUrl,
      isAvailable: product.isAvailable,
      isFeatured: product.isFeatured,
      sortOrder: product.sortOrder,
      createdAt: product.createdAt,
      nutrition,
      variants: includeVariants && product.variants
        ? product.variants.map(
            (v) =>
              new ProductVariantDto({
                id: v.id,
                name: v.name,
                sizeMl: v.sizeMl,
                priceModifier: Number(v.priceModifier),
                isDefault: v.isDefault,
                sortOrder: v.sortOrder,
              }),
          )
        : [],
    });
  }
}
