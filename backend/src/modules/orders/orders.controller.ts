import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { OrdersService } from './orders.service';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';
import { CreateOrderDto } from './dto/create-order.dto';
import { OrderResponseDto } from './dto/order-response.dto';

@Controller('orders')
@UseGuards(AuthGuard('jwt'))
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post()
  async create(
    @CurrentUser() user: User,
    @Body() dto: CreateOrderDto,
  ): Promise<OrderResponseDto> {
    return this.ordersService.create(user.id, dto);
  }

  @Get()
  async findAll(@CurrentUser() user: User): Promise<OrderResponseDto[]> {
    return this.ordersService.findAllByUser(user.id);
  }

  @Get(':id')
  async findById(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ): Promise<OrderResponseDto> {
    return this.ordersService.findById(user.id, id);
  }

  @Post(':id/cancel')
  async cancel(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ): Promise<OrderResponseDto> {
    return this.ordersService.cancel(user.id, id);
  }

  @Post(':id/reorder')
  async reorder(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ): Promise<OrderResponseDto> {
    return this.ordersService.reorder(user.id, id);
  }
}
