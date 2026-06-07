export class CartItemResponseDto {
  id: string;
  productId: string;
  productName: string;
  productImage?: string;
  unitPrice: number;
  quantity: number;
  totalPrice: number;
  notes?: string;

  constructor(partial: Partial<CartItemResponseDto>) {
    Object.assign(this, partial);
  }
}

export class CartResponseDto {
  id: string;
  items: CartItemResponseDto[];
  storeId?: string;
  storeName?: string;
  notes?: string;
  subtotal: number;
  tax: number;
  total: number;
  itemCount: number;

  constructor(partial: Partial<CartResponseDto>) {
    Object.assign(this, partial);
    if (partial.items) {
      this.items = partial.items.map((i) => new CartItemResponseDto(i));
    }
  }
}
