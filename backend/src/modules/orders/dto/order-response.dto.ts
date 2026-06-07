export class OrderItemResponseDto {
  id: string;
  productId: string;
  productName: string;
  productImage?: string;
  unitPrice: number;
  quantity: number;
  totalPrice: number;
  notes?: string;

  constructor(partial: Partial<OrderItemResponseDto>) {
    Object.assign(this, partial);
  }
}

export class OrderResponseDto {
  id: string;
  items: OrderItemResponseDto[];
  status: string;
  subtotal: number;
  tax: number;
  total: number;
  storeId?: string;
  storeName?: string;
  notes?: string;
  createdAt: string;
  updatedAt?: string;

  constructor(partial: Partial<OrderResponseDto>) {
    Object.assign(this, partial);
    if (partial.items) {
      this.items = partial.items.map((i) => new OrderItemResponseDto(i));
    }
  }
}
