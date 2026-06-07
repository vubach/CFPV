import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cfpv/core/network/dio_client.dart';
import 'package:cfpv/features/cart/model/cart_model.dart';
import 'package:cfpv/features/cart/model/cart_item_model.dart';
import 'package:cfpv/features/cart/presentation/pages/cart_page.dart';
import 'package:cfpv/features/cart/provider/cart_provider.dart';
import 'package:cfpv/features/cart/repository/cart_repository.dart';
import 'package:cfpv/features/cart/state/cart_state.dart';

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

/// A mock repository that keeps cart state in memory for interaction tests.
class _StubCartRepository extends CartRepository {
  Cart _cart = const Cart();
  bool _shouldThrow = false;

  _StubCartRepository()
      : super(dioClient: DioClient.create(baseUrl: 'http://test.local'));

  void setCart(Cart cart) {
    _cart = cart;
    _shouldThrow = false;
  }

  Cart get cart => _cart;

  void setShouldThrow(bool value) {
    _shouldThrow = value;
  }

  @override
  Future<Cart> fetchCart() async {
    if (_shouldThrow) throw Exception('Failed to fetch cart');
    return _cart;
  }

  @override
  Future<void> updateItemQuantity({
    required String itemId,
    required int quantity,
  }) async {
    if (_shouldThrow) throw Exception('Failed to update item');
    final items = _cart.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(
          quantity: quantity,
          totalPrice: item.unitPrice * quantity,
        );
      }
      return item;
    }).toList();
    final subtotal = items.fold<double>(0.0, (sum, i) => sum + i.totalPrice);
    _cart = _cart.copyWith(
      items: items,
      subtotal: subtotal,
      tax: subtotal * 0.08,
      total: subtotal * 1.08,
      itemCount: items.length,
    );
  }

  @override
  Future<void> removeItem(String itemId) async {
    if (_shouldThrow) throw Exception('Failed to remove item');
    final items = _cart.items.where((i) => i.id != itemId).toList();
    final subtotal = items.fold<double>(0.0, (sum, i) => sum + i.totalPrice);
    _cart = _cart.copyWith(
      items: items,
      subtotal: subtotal,
      tax: subtotal * 0.08,
      total: subtotal * 1.08,
      itemCount: items.length,
    );
  }

  @override
  Future<void> clearCart() async {
    if (_shouldThrow) throw Exception('Failed to clear cart');
    _cart = const Cart();
  }
}

/// Helper: build a CartPage with a stub repo driving a real CartNotifier.
Widget _buildApp(_StubCartRepository repo) {
  return ProviderScope(
    overrides: [
      cartProvider.overrideWithProvider(
        StateNotifierProvider<CartNotifier, CartState>(
          (ref) => CartNotifier(repo),
        ),
      ),
    ],
    child: const MaterialApp(home: CartPage()),
  );
}

void main() {
  group('CartPage', () {
    // ── State tests ─────────────────────────────────

    testWidgets('shows empty state when cart is empty', (tester) async {
      final repo = _StubCartRepository();
      repo.setCart(const Cart());

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Browse Menu'), findsOneWidget);
    });

    testWidgets('shows error state with retry button', (tester) async {
      final repo = _StubCartRepository();
      repo.setShouldThrow(true);

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      expect(find.text('Could not load cart'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('shows cart items and totals when loaded', (tester) async {
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

      final repo = _StubCartRepository();
      repo.setCart(Cart(
        id: 'cart-1',
        items: items,
        storeId: 'store-1',
        storeName: 'Test Store',
        subtotal: 14.75,
        tax: 1.18,
        total: 15.93,
        itemCount: items.length,
      ),);

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      expect(find.text('Caffe Latte'), findsOneWidget);
      expect(find.text('Iced Coffee'), findsOneWidget);
      expect(find.text('\$5.50'), findsOneWidget);
      expect(find.text('\$3.75'), findsWidgets);
      expect(find.text('\$11.00'), findsOneWidget);
      expect(find.text('Subtotal'), findsWidgets);
      expect(find.text('Tax'), findsWidgets);
      expect(find.text('Total'), findsWidgets);
      expect(find.textContaining('Checkout'), findsOneWidget);
    });

    testWidgets('shows correct tax and grand total', (tester) async {
      final items = [
        _createItem(
          id: 'item-1',
          productName: 'Cold Brew',
          unitPrice: 4.50,
          quantity: 3,
        ),
      ];

      final repo = _StubCartRepository();
      repo.setCart(Cart(
        id: 'cart-1',
        items: items,
        subtotal: 13.50,
        tax: 1.08,
        total: 14.58,
        itemCount: 1,
      ),);

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      expect(find.text('\$13.50'), findsWidgets);
      expect(find.text('\$1.08'), findsOneWidget);
      expect(find.text('\$14.58'), findsOneWidget);
    });

    testWidgets('shows Clear button when cart has items', (tester) async {
      final items = [
        _createItem(id: 'item-1', productName: 'Latte', quantity: 1),
      ];

      final repo = _StubCartRepository();
      repo.setCart(Cart(
        id: 'cart-1',
        items: items,
        subtotal: 5.0,
        tax: 0.40,
        total: 5.40,
        itemCount: 1,
      ),);

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('does not show Clear button when cart is empty', (tester) async {
      final repo = _StubCartRepository();
      repo.setCart(const Cart());

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      expect(find.text('Clear'), findsNothing);
    });

    // ── Interaction tests ──────────────────────────

    testWidgets('tapping + increments quantity', (tester) async {
      final items = [
        _createItem(
          id: 'item-1',
          productName: 'Latte',
          unitPrice: 5.00,
          quantity: 2,
        ),
      ];

      final repo = _StubCartRepository();
      repo.setCart(Cart(
        id: 'cart-1',
        items: items,
        subtotal: 10.00,
        tax: 0.80,
        total: 10.80,
        itemCount: 1,
      ),);

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      // Mock repo returns synchronously, so pumpAndSettle handles it
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
      // $15.00 appears as line total AND subtotal
      expect(find.text('\$15.00'), findsWidgets);
    });

    testWidgets('tapping - decrements quantity', (tester) async {
      final items = [
        _createItem(
          id: 'item-1',
          productName: 'Latte',
          unitPrice: 5.00,
          quantity: 3,
        ),
      ];

      final repo = _StubCartRepository();
      repo.setCart(Cart(
        id: 'cart-1',
        items: items,
        subtotal: 15.00,
        tax: 1.20,
        total: 16.20,
        itemCount: 1,
      ),);

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
      // $10.00 appears as line total AND subtotal
      expect(find.text('\$10.00'), findsWidgets);
    });

    testWidgets('tapping - at quantity 1 removes the item', (tester) async {
      final items = [
        _createItem(
          id: 'item-1',
          productName: 'Latte',
          unitPrice: 5.00,
          quantity: 1,
        ),
      ];

      final repo = _StubCartRepository();
      repo.setCart(Cart(
        id: 'cart-1',
        items: items,
        subtotal: 5.00,
        tax: 0.40,
        total: 5.40,
        itemCount: 1,
      ),);

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      expect(find.text('Latte'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(find.text('Latte'), findsNothing);
      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Clear'), findsNothing);
    });

    testWidgets('tapping close button removes the item', (tester) async {
      final items = [
        _createItem(id: 'item-1', productName: 'Latte', quantity: 1),
        _createItem(
          id: 'item-2',
          productName: 'Mocha',
          unitPrice: 5.50,
          quantity: 2,
        ),
      ];

      final repo = _StubCartRepository();
      repo.setCart(Cart(
        id: 'cart-1',
        items: items,
        subtotal: 16.00,
        tax: 1.28,
        total: 17.28,
        itemCount: 2,
      ),);

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      expect(find.text('Latte'), findsOneWidget);
      expect(find.text('Mocha'), findsOneWidget);

      // Two close buttons exist (one per item); tap the first one
      final closeButtons = find.byIcon(Icons.close);
      expect(closeButtons, findsNWidgets(2));
      await tester.tap(closeButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Latte'), findsNothing);
      expect(find.text('Mocha'), findsOneWidget);
      // $11.00 appears as Mocha line total AND new subtotal
      expect(find.text('\$11.00'), findsWidgets);
    });

    testWidgets('swiping left on an item removes it via Dismissible',
        (tester) async {
      final items = [
        _createItem(id: 'item-1', productName: 'Latte', quantity: 1),
        _createItem(
          id: 'item-2',
          productName: 'Mocha',
          unitPrice: 5.50,
          quantity: 2,
        ),
      ];

      final repo = _StubCartRepository();
      repo.setCart(Cart(
        id: 'cart-1',
        items: items,
        subtotal: 16.00,
        tax: 1.28,
        total: 17.28,
        itemCount: 2,
      ),);

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      // Both items visible
      expect(find.text('Latte'), findsOneWidget);
      expect(find.text('Mocha'), findsOneWidget);
      expect(find.byType(Dismissible), findsNWidgets(2));

      // Swipe the first Dismissible to the left (endToStart)
      await tester.drag(
        find.byType(Dismissible).first,
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();

      // Swiped item (Latte) should be gone, Mocha remains
      expect(find.text('Latte'), findsNothing);
      expect(find.text('Mocha'), findsOneWidget);
      expect(find.byType(Dismissible), findsOneWidget);

      // Total should be Mocha's: 5.50 * 2 = 11.00 (line total + subtotal)
      expect(find.text('\$11.00'), findsWidgets);
    });

    testWidgets('Clear cart clears all items', (tester) async {
      final items = [
        _createItem(id: 'item-1', productName: 'Latte', quantity: 1),
        _createItem(id: 'item-2', productName: 'Mocha', quantity: 2),
      ];

      final repo = _StubCartRepository();
      repo.setCart(Cart(
        id: 'cart-1',
        items: items,
        subtotal: 16.00,
        tax: 1.28,
        total: 17.28,
        itemCount: 2,
      ),);

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      // Tap Clear in the app bar
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // Confirmation dialog shown
      expect(find.text('Clear Cart'), findsOneWidget);
      expect(
        find.text('Are you sure you want to remove all items from your cart?'),
        findsOneWidget,
      );

      // Confirm clear
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Latte'), findsNothing);
      expect(find.text('Mocha'), findsNothing);
    });
  });
}
