import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Cart } from './entities/cart.entity';
import { CartItem } from './entities/cart-item.entity';
import { Product } from '../products/entities/product.entity';
import { AddCartItemDto } from './dto/add-cart-item.dto';
import { UpdateCartItemDto } from './dto/update-cart-item.dto';
import { CartResponseDto, CartItemResponseDto } from './dto/cart-response.dto';

@Injectable()
export class CartService {
  private readonly logger = new Logger(CartService.name);

  constructor(
    @InjectRepository(Cart)
    private readonly cartRepo: Repository<Cart>,
    @InjectRepository(CartItem)
    private readonly cartItemRepo: Repository<CartItem>,
    @InjectRepository(Product)
    private readonly productRepo: Repository<Product>,
  ) {}

  private readonly TAX_RATE = 0.10;

  async getCart(userId: string): Promise<CartResponseDto> {
    let cart = await this.cartRepo.findOne({
      where: { userId },
      relations: ['items'],
      order: { items: { createdAt: 'ASC' } },
    });

    if (!cart) {
      cart = this.cartRepo.create({ userId, items: [] });
      cart = await this.cartRepo.save(cart);
    }

    return this.toResponse(cart);
  }

  async addItem(userId: string, dto: AddCartItemDto): Promise<CartResponseDto> {
    const product = await this.productRepo.findOne({ where: { id: dto.productId } });
    if (!product) {
      throw new NotFoundException('Product not found');
    }

    if (!product.isAvailable) {
      throw new BadRequestException('Product is not available');
    }

    let cart = await this.cartRepo.findOne({
      where: { userId },
      relations: ['items'],
    });

    if (!cart) {
      cart = this.cartRepo.create({ userId, items: [] });
      cart = await this.cartRepo.save(cart);
    }

    const unitPrice = Number(product.price);
    const totalPrice = unitPrice * dto.quantity;

    const cartItem = this.cartItemRepo.create({
      cartId: cart.id,
      productId: product.id,
      variantId: dto.variantId,
      productName: product.name,
      productImage: product.imageUrl,
      unitPrice,
      quantity: dto.quantity,
      totalPrice,
      notes: dto.notes,
    });

    await this.cartItemRepo.save(cartItem);

    cart = await this.cartRepo.findOne({
      where: { id: cart.id },
      relations: ['items'],
      order: { items: { createdAt: 'ASC' } },
    });

    this.logger.log(`Item added to cart: ${product.name} x${dto.quantity}`);
    return this.toResponse(cart!);
  }

  async updateItemQuantity(
    userId: string,
    itemId: string,
    dto: UpdateCartItemDto,
  ): Promise<CartResponseDto> {
    const cart = await this.ensureCartOwnership(userId, itemId);

    const cartItem = cart.items.find((i) => i.id === itemId);
    if (!cartItem) {
      throw new NotFoundException('Cart item not found');
    }

    if (dto.quantity === 0) {
      await this.cartItemRepo.remove(cartItem);
    } else {
      cartItem.quantity = dto.quantity;
      cartItem.totalPrice = Number(cartItem.unitPrice) * dto.quantity;
      await this.cartItemRepo.save(cartItem);
    }

    const updatedCart = await this.cartRepo.findOne({
      where: { id: cart.id },
      relations: ['items'],
      order: { items: { createdAt: 'ASC' } },
    });

    return this.toResponse(updatedCart!);
  }

  async removeItem(userId: string, itemId: string): Promise<CartResponseDto> {
    const cart = await this.ensureCartOwnership(userId, itemId);

    const cartItem = cart.items.find((i) => i.id === itemId);
    if (!cartItem) {
      throw new NotFoundException('Cart item not found');
    }

    await this.cartItemRepo.remove(cartItem);

    const updatedCart = await this.cartRepo.findOne({
      where: { id: cart.id },
      relations: ['items'],
      order: { items: { createdAt: 'ASC' } },
    });

    return this.toResponse(updatedCart!);
  }

  async clearCart(userId: string): Promise<CartResponseDto> {
    const cart = await this.cartRepo.findOne({
      where: { userId },
      relations: ['items'],
    });

    if (cart) {
      await this.cartItemRepo.remove(cart.items);
      cart.storeId = undefined as any;
      cart.storeName = undefined as any;
      cart.notes = undefined as any;
      await this.cartRepo.save(cart);
    }

    return this.getCart(userId);
  }

  async updateStore(
    userId: string,
    storeId?: string,
    storeName?: string,
  ): Promise<CartResponseDto> {
    let cart = await this.cartRepo.findOne({ where: { userId } });

    if (!cart) {
      cart = this.cartRepo.create({ userId });
    }

    if (storeId !== undefined) cart.storeId = storeId;
    if (storeName !== undefined) cart.storeName = storeName;

    await this.cartRepo.save(cart);
    return this.getCart(userId);
  }

  async updateNotes(userId: string, notes?: string): Promise<CartResponseDto> {
    let cart = await this.cartRepo.findOne({ where: { userId } });

    if (!cart) {
      cart = this.cartRepo.create({ userId });
    }

    cart.notes = notes ?? null as any;
    await this.cartRepo.save(cart);

    return this.getCart(userId);
  }

  private async ensureCartOwnership(
    userId: string,
    itemId: string,
  ): Promise<Cart> {
    const cart = await this.cartRepo.findOne({
      where: { userId },
      relations: ['items'],
    });

    if (!cart) {
      throw new NotFoundException('Cart not found');
    }

    const belongsToCart = cart.items.some((i) => i.id === itemId);
    if (!belongsToCart) {
      throw new NotFoundException('Cart item not found');
    }

    return cart;
  }

  private toResponse(cart: Cart): CartResponseDto {
    const items = (cart.items ?? []).map(
      (item) =>
        new CartItemResponseDto({
          id: item.id,
          productId: item.productId,
          productName: item.productName,
          productImage: item.productImage,
          unitPrice: Number(item.unitPrice),
          quantity: item.quantity,
          totalPrice: Number(item.totalPrice),
          notes: item.notes,
        }),
    );

    const subtotal = items.reduce((sum, item) => sum + item.totalPrice, 0);
    const tax = subtotal * this.TAX_RATE;
    const total = subtotal + tax;
    const itemCount = items.reduce((sum, item) => sum + item.quantity, 0);

    return new CartResponseDto({
      id: cart.id,
      items,
      storeId: cart.storeId,
      storeName: cart.storeName,
      notes: cart.notes,
      subtotal: Math.round(subtotal * 100) / 100,
      tax: Math.round(tax * 100) / 100,
      total: Math.round(total * 100) / 100,
      itemCount,
    });
  }
}
