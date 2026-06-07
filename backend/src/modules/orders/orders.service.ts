import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Order } from './entities/order.entity';
import { OrderItem } from './entities/order-item.entity';
import { OrderStatus, ACTIVE_ORDER_STATUSES } from './entities/order-status.enum';
import { Cart } from '../cart/entities/cart.entity';
import { CartItem } from '../cart/entities/cart-item.entity';
import { RewardsService } from '../rewards/rewards.service';
import { NotificationsService } from '../notifications/notifications.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { OrderResponseDto, OrderItemResponseDto } from './dto/order-response.dto';

@Injectable()
export class OrdersService {
  private readonly logger = new Logger(OrdersService.name);

  private readonly TAX_RATE = 0.10;

  constructor(
    @InjectRepository(Order)
    private readonly orderRepo: Repository<Order>,
    @InjectRepository(OrderItem)
    private readonly orderItemRepo: Repository<OrderItem>,
    @InjectRepository(Cart)
    private readonly cartRepo: Repository<Cart>,
    @InjectRepository(CartItem)
    private readonly cartItemRepo: Repository<CartItem>,
    private readonly rewardsService: RewardsService,
    private readonly notificationsService: NotificationsService,
  ) {}

  async create(userId: string, dto: CreateOrderDto): Promise<OrderResponseDto> {
    const cart = await this.cartRepo.findOne({
      where: { userId },
      relations: ['items'],
    });

    if (!cart || !cart.items || cart.items.length === 0) {
      throw new BadRequestException('Cart is empty');
    }

    const subtotal = cart.items.reduce(
      (sum, item) => sum + Number(item.totalPrice),
      0,
    );
    const tax = Math.round(subtotal * this.TAX_RATE * 100) / 100;
    const total = Math.round((subtotal + tax) * 100) / 100;

    const order = this.orderRepo.create({
      userId,
      storeId: dto.storeId ?? cart.storeId,
      storeName: cart.storeName,
      notes: dto.notes ?? cart.notes,
      status: OrderStatus.PENDING,
      subtotal,
      tax,
      total,
    });

    const savedOrder = await this.orderRepo.save(order);

    const orderItems = cart.items.map((ci) =>
      this.orderItemRepo.create({
        orderId: savedOrder.id,
        productId: ci.productId,
        productName: ci.productName,
        productImage: ci.productImage,
        unitPrice: Number(ci.unitPrice),
        quantity: ci.quantity,
        totalPrice: Number(ci.totalPrice),
        notes: ci.notes,
      }),
    );

    await this.orderItemRepo.save(orderItems);

    await this.cartItemRepo.remove(cart.items);
    cart.storeId = undefined as any;
    cart.storeName = undefined as any;
    cart.notes = undefined as any;
    await this.cartRepo.save(cart);

    try {
      const pointsEarned = Math.floor(total / 1000);
      if (pointsEarned > 0) {
        await this.rewardsService.earnPoints(
          userId,
          savedOrder.id,
          pointsEarned,
          `Order #${savedOrder.id.slice(0, 8)}`,
        );
      }
      try {
        await this.notificationsService.sendToUser(
          userId,
          'Reward Earned!',
          `You earned ${pointsEarned}★ for order #${savedOrder.id.slice(0, 8)}.`,
          { type: 'reward_earned', orderId: savedOrder.id, points: String(pointsEarned) },
        );
      } catch (err) {
        this.logger.warn(`Failed to send reward notification: ${err}`);
      }
    } catch (err) {
      this.logger.warn(`Failed to credit points for order ${savedOrder.id}: ${err}`);
    }

    const orderWithItems = await this.orderRepo.findOne({
      where: { id: savedOrder.id },
      relations: ['items'],
    });

    try {
      await this.notificationsService.sendToUser(
        userId,
        'Order Confirmed!',
        `Your order #${savedOrder.id.slice(0, 8)} has been placed and is being prepared.`,
        { type: 'order_confirmed', orderId: savedOrder.id },
      );
    } catch (err) {
      this.logger.warn(`Failed to send order notification: ${err}`);
    }

    this.logger.log(`Order created: ${savedOrder.id} (${total} VND)`);
    return this.toResponse(orderWithItems!);
  }

  async findAllByUser(userId: string): Promise<OrderResponseDto[]> {
    const orders = await this.orderRepo.find({
      where: { userId },
      relations: ['items'],
      order: { createdAt: 'DESC' },
    });
    return orders.map((o) => this.toResponse(o));
  }

  async findById(userId: string, orderId: string): Promise<OrderResponseDto> {
    const order = await this.orderRepo.findOne({
      where: { id: orderId, userId },
      relations: ['items'],
    });
    if (!order) {
      throw new NotFoundException('Order not found');
    }
    return this.toResponse(order);
  }

  async cancel(userId: string, orderId: string): Promise<OrderResponseDto> {
    const order = await this.orderRepo.findOne({
      where: { id: orderId, userId },
      relations: ['items'],
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (!ACTIVE_ORDER_STATUSES.includes(order.status)) {
      throw new BadRequestException(
        `Order cannot be cancelled in "${order.status}" status`,
      );
    }

    order.status = OrderStatus.CANCELLED;
    const saved = await this.orderRepo.save(order);

    this.logger.log(`Order cancelled: ${orderId}`);
    return this.toResponse(saved);
  }

  async reorder(userId: string, orderId: string): Promise<OrderResponseDto> {
    const order = await this.orderRepo.findOne({
      where: { id: orderId, userId },
      relations: ['items'],
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    let cart = await this.cartRepo.findOne({
      where: { userId },
    });

    if (!cart) {
      cart = this.cartRepo.create({ userId });
      cart = await this.cartRepo.save(cart);
    }

    for (const oi of order.items) {
      const existingItem = await this.cartItemRepo.findOne({
        where: { cartId: cart.id, productId: oi.productId },
      });

      if (existingItem) {
        existingItem.quantity += oi.quantity;
        existingItem.totalPrice = Number(existingItem.unitPrice) * existingItem.quantity;
        await this.cartItemRepo.save(existingItem);
      } else {
        const newItem = this.cartItemRepo.create({
          cartId: cart.id,
          productId: oi.productId,
          productName: oi.productName,
          productImage: oi.productImage,
          unitPrice: Number(oi.unitPrice),
          quantity: oi.quantity,
          totalPrice: Number(oi.totalPrice),
          notes: oi.notes,
        });
        await this.cartItemRepo.save(newItem);
      }
    }

    this.logger.log(`Order reordered: ${orderId}`);
    return this.toResponse(order);
  }

  toResponse(order: Order): OrderResponseDto {
    const items = (order.items ?? []).map(
      (item) =>
        new OrderItemResponseDto({
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

    return new OrderResponseDto({
      id: order.id,
      items,
      status: order.status,
      subtotal: Number(order.subtotal),
      tax: Number(order.tax),
      total: Number(order.total),
      storeId: order.storeId,
      storeName: order.storeName,
      notes: order.notes,
      createdAt: order.createdAt.toISOString(),
      updatedAt: order.updatedAt?.toISOString(),
    });
  }
}
