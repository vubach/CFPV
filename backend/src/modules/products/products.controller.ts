import { Controller, Get, Param, Query } from '@nestjs/common';
import { ProductsService } from './products.service';
import { Public } from '../../common/decorators/public.decorator';
import { ProductResponseDto } from './dto/product-response.dto';
import { ProductListQueryDto } from './dto/product-list-query.dto';

@Controller('products')
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Public()
  @Get()
  async findAll(@Query() query: ProductListQueryDto): Promise<ProductResponseDto[]> {
    return this.productsService.findAll(query);
  }

  @Public()
  @Get('featured')
  async findFeatured(): Promise<ProductResponseDto[]> {
    return this.productsService.findFeatured();
  }

  @Public()
  @Get(':id')
  async findById(@Param('id') id: string): Promise<ProductResponseDto> {
    return this.productsService.findById(id);
  }
}
