import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:cfpv/core/network/dio_client.dart';
import 'package:cfpv/features/cart/model/cart_model.dart';
import 'package:cfpv/features/cart/model/cart_item_model.dart';
import 'package:cfpv/features/cart/provider/cart_provider.dart';
import 'package:cfpv/features/cart/repository/cart_repository.dart';
import 'package:cfpv/features/cart/state/cart_state.dart';
import 'package:cfpv/features/checkout/presentation/pages/checkout_page.dart';
import 'package:cfpv/features/orders/model/order_model.dart';
import 'package:cfpv/features/orders/provider/order_provider.dart';
import 'package:cfpv/features/orders/repository/order_repository.dart';
import 'package:cfpv/features/orders/state/order_state.dart';

/// Creates a test cart item.
CartItem _createItem({
  String id = 'item-1',
  String productId = 'prod-1',
  String productName = 'Caffe Latte',
  double unitPrice = 5.0,
  int quantity = 2,
}) {
  return CartItem(
    id: id,
    productId: productId,
    productName: productName,
    unitPrice: unitPrice,
    quantity: quantity,
    totalPrice: unitPrice * quantity,
  );
}

/// A stub cart repository that keeps state in memory.
class _StubCartRepository extends CartRepository {
  Cart _cart = const Cart();
  bool _shouldThrow = false;

  _StubCartRepository()
      : super(dioClient: DioClient.create(baseUrl: 'http://test.local'));

  void setCart(Cart cart) {
    _cart = cart;
    _shouldThrow = false;
  }

  @override
  Future<Cart> fetchCart() async {
    if (_shouldThrow) throw Exception('Failed to fetch cart');
    return _cart;
  }

  @override
  Future<CartItem> addItem({
    required String productId,
    required int quantity,
    String? notes,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateItemQuantity({
    required String itemId,
    required int quantity,
  }) async {}

  @override
  Future<void> removeItem(String itemId) async {}

  @override
  Future<void> clearCart() async {
    _cart = const Cart();
  }
}

/// A stub order repository with controlled success/failure.
class _StubOrderRepository extends OrderRepository {
  bool _shouldThrow = false;

  _StubOrderRepository()
      : super(dioClient: DioClient.create(baseUrl: 'http://test.local'));

  void setShouldThrow(bool value) {
    _shouldThrow = value;
  }

  @override
  Future<Order> placeOrder({
    List<Map<String, dynamic>>? items,
    String? storeId,
    String? notes,
  }) async {
    if (_shouldThrow) throw Exception('Payment failed');
    return Order(
      id: 'order-1',
      items: [],
      status: OrderStatus.confirmed,
      subtotal: 5.00,
      tax: 0.40,
      total: 5.40,
      storeId: 'store-1',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<Order>> fetchOrders() async {
    return [];
  }

  @override
  Future<Order> cancelOrder(String orderId) async {
    throw UnimplementedError();
  }
}

/// Helper: build app with providers wired to stub repos and a minimal GoRouter.
Widget _buildApp({
  required _StubCartRepository cartRepo,
  required _StubOrderRepository orderRepo,
}) {
  final goRouter = GoRouter(
    initialLocation: '/checkout',
    routes: [
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (_, __) => const CheckoutPage(),
      ),
      GoRoute(
        path: '/profile/orders',
        name: 'profileOrders',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('Orders Page'))),
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('Cart Page'))),
      ),
      GoRoute(
        path: '/menu',
        name: 'menu',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('Menu Page'))),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      cartProvider.overrideWithProvider(
        StateNotifierProvider<CartNotifier, CartState>(
          (ref) => CartNotifier(cartRepo),
        ),
      ),
      orderProvider.overrideWithProvider(
        StateNotifierProvider<OrderNotifier, OrderState>(
          (ref) => OrderNotifier(orderRepo),
        ),
      ),
    ],
    child: MaterialApp.router(
      routerConfig: goRouter,
    ),
  );
}

void main() {
  group('CheckoutPage', () {
    testWidgets('shows empty state when cart is empty', (tester) async {
      final cartRepo = _StubCartRepository();
      cartRepo.setCart(const Cart());

      final orderRepo = _StubOrderRepository();

      await tester.pumpWidget(_buildApp(
        cartRepo: cartRepo,
        orderRepo: orderRepo,
      ),);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Browse Menu'), findsOneWidget);
    });

    testWidgets('shows order summary items and totals', (tester) async {
      final items = [
        _createItem(
          id: 'item-1',
          productName: 'Caffe Latte',
          unitPrice: 5.50,
          quantity: 2,
        ),
        _createItem(
          id: 'item-2',
          productName: 'Iced Coffee',
          unitPrice: 3.75,
          quantity: 1,
        ),
      ];

      final cartRepo = _StubCartRepository();
      cartRepo.setCart(Cart(
        id: 'cart-1',
        items: items,
        subtotal: 14.75,
        tax: 1.18,
        total: 15.93,
        itemCount: items.length,
      ),);

      final orderRepo = _StubOrderRepository();

      await tester.pumpWidget(_buildApp(
        cartRepo: cartRepo,
        orderRepo: orderRepo,
      ),);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Checkout'), findsWidgets);
      expect(find.text('Caffe Latte'), findsOneWidget);
      expect(find.text('Iced Coffee'), findsOneWidget);

      // Use contains match to avoid × vs x encoding issues
      expect(
        find.textContaining('Qty: 2'),
        findsOneWidget,
      );
      expect(find.textContaining('\$5.50'), findsWidgets);

      // Totals: subtotal appears in totals card + bottom bar
      expect(find.text('\$14.75'), findsWidgets);
      expect(find.text('\$1.18'), findsOneWidget);
      // Total appears in the totals card AND the bottom bar
      expect(find.text('\$15.93'), findsWidgets);

      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Place Order — 2 items'), findsOneWidget);
    });

    testWidgets('shows correct button text for single item', (tester) async {
      final items = [
        _createItem(id: 'item-1', productName: 'Latte', quantity: 1),
      ];

      final cartRepo = _StubCartRepository();
      cartRepo.setCart(Cart(
        id: 'cart-1',
        items: items,
        subtotal: 5.00,
        tax: 0.40,
        total: 5.40,
        itemCount: 1,
      ),);

      final orderRepo = _StubOrderRepository();

      await tester.pumpWidget(_buildApp(
        cartRepo: cartRepo,
        orderRepo: orderRepo,
      ),);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Place Order — 1 item'), findsOneWidget);
    });

    testWidgets('payment method options are tappable', (tester) async {
      final items = [
        _createItem(id: 'item-1', productName: 'Latte', quantity: 1),
      ];

      final cartRepo = _StubCartRepository();
      cartRepo.setCart(Cart(
        id: 'cart-1',
        items: items,
        subtotal: 5.00,
        tax: 0.40,
        total: 5.40,
        itemCount: 1,
      ),);

      final orderRepo = _StubOrderRepository();

      await tester.pumpWidget(_buildApp(
        cartRepo: cartRepo,
        orderRepo: orderRepo,
      ),);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Credit / Debit Card'), findsOneWidget);
      expect(find.text('PayPal'), findsOneWidget);
      expect(find.text('Cash on Pickup'), findsOneWidget);

      await tester.tap(find.text('PayPal'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cash on Pickup'));
      await tester.pumpAndSettle();
    });

    testWidgets('placing order successfully shows success snackbar',
        (tester) async {
      final items = [
        _createItem(id: 'item-1', productName: 'Latte', quantity: 1),
      ];

      final cartRepo = _StubCartRepository();
      cartRepo.setCart(Cart(
        id: 'cart-1',
        items: items,
        subtotal: 5.00,
        tax: 0.40,
        total: 5.40,
        itemCount: 1,
      ),);

      final orderRepo = _StubOrderRepository();
      orderRepo.setShouldThrow(false);

      await tester.pumpWidget(_buildApp(
        cartRepo: cartRepo,
        orderRepo: orderRepo,
      ),);
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Place Order — 1 item'));
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();

      expect(find.text('Order placed successfully!'), findsOneWidget);
    });

    testWidgets('shows error snackbar when order fails', (tester) async {
      final items = [
        _createItem(id: 'item-1', productName: 'Latte', quantity: 1),
      ];

      final cartRepo = _StubCartRepository();
      cartRepo.setCart(Cart(
        id: 'cart-1',
        items: items,
        subtotal: 5.00,
        tax: 0.40,
        total: 5.40,
        itemCount: 1,
      ),);

      final orderRepo = _StubOrderRepository();
      orderRepo.setShouldThrow(true);

      await tester.pumpWidget(_buildApp(
        cartRepo: cartRepo,
        orderRepo: orderRepo,
      ),);
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Place Order — 1 item'));
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to place order'), findsOneWidget);
    });
  });
}
