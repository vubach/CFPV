import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { CartService } from './cart.service';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';
import { AddCartItemDto } from './dto/add-cart-item.dto';
import { UpdateCartItemDto } from './dto/update-cart-item.dto';
import { UpdateCartStoreDto } from './dto/update-cart-store.dto';
import { UpdateCartNotesDto } from './dto/update-cart-notes.dto';
import { CartResponseDto } from './dto/cart-response.dto';

@Controller('cart')
@UseGuards(AuthGuard('jwt'))
export class CartController {
  constructor(private readonly cartService: CartService) {}

  @Get()
  async getCart(@CurrentUser() user: User): Promise<CartResponseDto> {
    return this.cartService.getCart(user.id);
  }

  @Post('items')
  async addItem(
    @CurrentUser() user: User,
    @Body() dto: AddCartItemDto,
  ): Promise<CartResponseDto> {
    return this.cartService.addItem(user.id, dto);
  }

  @Patch('items/:itemId')
  async updateItemQuantity(
    @CurrentUser() user: User,
    @Param('itemId') itemId: string,
    @Body() dto: UpdateCartItemDto,
  ): Promise<CartResponseDto> {
    return this.cartService.updateItemQuantity(user.id, itemId, dto);
  }

  @Delete('items/:itemId')
  async removeItem(
    @CurrentUser() user: User,
    @Param('itemId') itemId: string,
  ): Promise<CartResponseDto> {
    return this.cartService.removeItem(user.id, itemId);
  }

  @Delete()
  async clearCart(@CurrentUser() user: User): Promise<CartResponseDto> {
    return this.cartService.clearCart(user.id);
  }

  @Patch('store')
  async updateStore(
    @CurrentUser() user: User,
    @Body() dto: UpdateCartStoreDto,
  ): Promise<CartResponseDto> {
    return this.cartService.updateStore(user.id, dto.storeId, dto.storeName);
  }

  @Patch('notes')
  async updateNotes(
    @CurrentUser() user: User,
    @Body() dto: UpdateCartNotesDto,
  ): Promise<CartResponseDto> {
    return this.cartService.updateNotes(user.id, dto.notes);
  }
}
