import 'package:flutter_test/flutter_test.dart';

import 'package:cfpv/core/network/dio_client.dart';
import 'package:cfpv/features/cart/model/cart_item_model.dart';
import 'package:cfpv/features/cart/model/cart_model.dart';
import 'package:cfpv/features/cart/provider/cart_provider.dart';
import 'package:cfpv/features/cart/repository/cart_repository.dart';
import 'package:cfpv/features/cart/state/cart_state.dart';

/// Mock repository that tracks internal state and can be configured to throw.
class _MockCartRepository extends CartRepository {
  final List<CartItem> _items = [];
  bool _shouldThrow = false;
  int _nextItemId = 1;

  _MockCartRepository()
      : super(dioClient: DioClient.create(baseUrl: 'http://test.local'));

  void setShouldThrow(bool value) {
    _shouldThrow = value;
  }

  void reset() {
    _items.clear();
    _shouldThrow = false;
    _nextItemId = 1;
  }

  int get itemCount => _items.length;

  Cart _buildCart() => Cart(
        id: 'cart-1',
        items: List.from(_items),
        storeId: 'store-1',
        storeName: 'Test Store',
        subtotal: _items.fold<double>(
            0.0, (sum, item) => sum + item.totalPrice,),
        total: _items.fold<double>(
            0.0, (sum, item) => sum + item.totalPrice,),
        itemCount: _items.length,
      );

  @override
  Future<Cart> fetchCart() async {
    if (_shouldThrow) throw Exception('Failed to fetch cart');
    return _buildCart();
  }

  @override
  Future<Cart> addItem({
    required String productId,
    required int quantity,
    String? notes,
  }) async {
    if (_shouldThrow) throw Exception('Failed to add item');
    final item = CartItem(
      id: 'item-${_nextItemId++}',
      productId: productId,
      productName: 'Product $productId',
      unitPrice: 5.0,
      quantity: quantity,
      totalPrice: 5.0 * quantity,
      notes: notes,
    );
    _items.add(item);
    return _buildCart();
  }

  @override
  Future<void> updateItemQuantity({
    required String itemId,
    required int quantity,
  }) async {
    if (_shouldThrow) throw Exception('Failed to update item');
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        quantity: quantity,
        totalPrice: _items[index].unitPrice * quantity,
      );
    }
  }

  @override
  Future<void> removeItem(String itemId) async {
    if (_shouldThrow) throw Exception('Failed to remove item');
    _items.removeWhere((i) => i.id == itemId);
  }

  @override
  Future<void> clearCart() async {
    if (_shouldThrow) throw Exception('Failed to clear cart');
    _items.clear();
  }
}

void main() {
  late _MockCartRepository mockRepo;
  late CartNotifier notifier;

  setUp(() {
    mockRepo = _MockCartRepository();
    notifier = CartNotifier(mockRepo);
  });

  tearDown(() {
    mockRepo.reset();
    notifier.dispose();
  });

  group('CartNotifier', () {
    testWidgets('starts with CartStateInitial', (_) async {
      expect(notifier.state, isA<CartStateInitial>());
      expect(notifier.state.isLoading, false);
      expect(notifier.state.hasError, false);
      expect(notifier.state.cart, isNull);
    });

    group('fetchCart()', () {
      testWidgets('emits loaded with cart on success', (tester) async {
        final future = notifier.fetchCart();

        expect(notifier.state, isA<CartStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<CartStateLoaded>());
        final cart = (notifier.state as CartStateLoaded).cart;
        expect(cart.id, 'cart-1');
        expect(cart.itemCount, 0); // No items added yet
        expect(cart.items, isEmpty);
      });

      testWidgets('emits loaded with items when items exist', (tester) async {
        // Pre-populate the mock repo
        mockRepo.addItem(productId: 'prod-1', quantity: 1);
        mockRepo.addItem(productId: 'prod-2', quantity: 3);

        final future = notifier.fetchCart();

        expect(notifier.state, isA<CartStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<CartStateLoaded>());
        final cart = (notifier.state as CartStateLoaded).cart;
        expect(cart.itemCount, 2);
        expect(cart.items[0].productId, 'prod-1');
        expect(cart.items[1].productId, 'prod-2');
        expect(cart.storeName, 'Test Store');
      });

      testWidgets('emits error on failure', (tester) async {
        mockRepo.setShouldThrow(true);

        final future = notifier.fetchCart();

        expect(notifier.state, isA<CartStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<CartStateError>());
        expect(
          (notifier.state as CartStateError).message,
          contains('Failed to fetch cart'),
        );
      });
    });

    group('addItem()', () {
      testWidgets('adds item and reloads cart on success', (tester) async {
        final future = notifier.addItem(
          productId: 'prod-1',
          quantity: 2,
        );

        expect(notifier.state, isA<CartStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<CartStateLoaded>());
        final cart = (notifier.state as CartStateLoaded).cart;
        expect(cart.itemCount, 1);
        expect(cart.items[0].productId, 'prod-1');
        expect(cart.items[0].quantity, 2);
      });

      testWidgets('adds item with notes on success', (tester) async {
        final future = notifier.addItem(
          productId: 'prod-1',
          quantity: 1,
          notes: 'Extra hot',
        );

        await tester.runAsync(() => future);

        expect(notifier.state, isA<CartStateLoaded>());
        final cart = (notifier.state as CartStateLoaded).cart;
        expect(cart.items[0].notes, 'Extra hot');
      });

      testWidgets('adds multiple items sequentially', (tester) async {
        await tester.runAsync(() async {
          await notifier.addItem(productId: 'prod-1', quantity: 1);
          await notifier.addItem(productId: 'prod-2', quantity: 3);
        });

        expect(notifier.state, isA<CartStateLoaded>());
        final cart = (notifier.state as CartStateLoaded).cart;
        expect(cart.itemCount, 2);
        expect(cart.items[0].productId, 'prod-1');
        expect(cart.items[1].productId, 'prod-2');
      });

      testWidgets('emits error on failure', (tester) async {
        mockRepo.setShouldThrow(true);

        final future = notifier.addItem(
          productId: 'prod-1',
          quantity: 1,
        );

        expect(notifier.state, isA<CartStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<CartStateError>());
        expect(
          (notifier.state as CartStateError).message,
          contains('Failed to add item'),
        );
      });
    });

    group('updateItemQuantity()', () {
      testWidgets('updates quantity and reloads cart on success',
          (tester) async {
        // Pre-populate with an item
        await tester.runAsync(
            () => notifier.addItem(productId: 'prod-1', quantity: 1),);

        final itemId =
            (notifier.state as CartStateLoaded).cart.items[0].id;

        final future =
            notifier.updateItemQuantity(itemId: itemId, quantity: 5);

        expect(notifier.state, isA<CartStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<CartStateLoaded>());
        final cart = (notifier.state as CartStateLoaded).cart;
        expect(cart.items[0].quantity, 5);
      });

      testWidgets('emits error on failure', (tester) async {
        mockRepo.setShouldThrow(true);

        final future = notifier.updateItemQuantity(
          itemId: 'nonexistent',
          quantity: 5,
        );

        expect(notifier.state, isA<CartStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<CartStateError>());
        expect(
          (notifier.state as CartStateError).message,
          contains('Failed to update item'),
        );
      });
    });

    group('removeItem()', () {
      testWidgets('removes item and reloads cart on success',
          (tester) async {
        // Pre-populate with two items
        await tester.runAsync(() async {
          await notifier.addItem(productId: 'prod-1', quantity: 1);
          await notifier.addItem(productId: 'prod-2', quantity: 2);
        });

        expect(
            (notifier.state as CartStateLoaded).cart.itemCount, 2,);

        final itemId =
            (notifier.state as CartStateLoaded).cart.items[0].id;

        final future = notifier.removeItem(itemId);

        expect(notifier.state, isA<CartStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<CartStateLoaded>());
        final cart = (notifier.state as CartStateLoaded).cart;
        expect(cart.itemCount, 1);
        expect(cart.items[0].productId, 'prod-2');
      });

      testWidgets('emits error on failure', (tester) async {
        mockRepo.setShouldThrow(true);

        final future = notifier.removeItem('nonexistent');

        expect(notifier.state, isA<CartStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<CartStateError>());
        expect(
          (notifier.state as CartStateError).message,
          contains('Failed to remove item'),
        );
      });
    });

    group('clearCart()', () {
      testWidgets('clears cart and emits empty cart on success',
          (tester) async {
        // Pre-populate with items
        await tester.runAsync(() async {
          await notifier.addItem(productId: 'prod-1', quantity: 1);
          await notifier.addItem(productId: 'prod-2', quantity: 2);
        });

        expect(
            (notifier.state as CartStateLoaded).cart.itemCount, 2,);

        final future = notifier.clearCart();

        expect(notifier.state, isA<CartStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<CartStateLoaded>());
        final cart = (notifier.state as CartStateLoaded).cart;
        expect(cart.itemCount, 0);
        expect(cart.items, isEmpty);
        expect(cart.isEmpty, isTrue);
      });

      testWidgets('clears empty cart gracefully', (tester) async {
        await tester.runAsync(() => notifier.fetchCart());

        expect(
            (notifier.state as CartStateLoaded).cart.itemCount, 0,);

        await tester.runAsync(() => notifier.clearCart());

        expect(notifier.state, isA<CartStateLoaded>());
        expect(
            (notifier.state as CartStateLoaded).cart.isEmpty, isTrue,);
      });

      testWidgets('emits error on failure', (tester) async {
        mockRepo.setShouldThrow(true);

        final future = notifier.clearCart();

        expect(notifier.state, isA<CartStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<CartStateError>());
        expect(
          (notifier.state as CartStateError).message,
          contains('Failed to clear cart'),
        );
      });
    });
  });
}
