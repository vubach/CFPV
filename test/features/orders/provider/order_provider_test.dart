import 'package:flutter_test/flutter_test.dart';

import 'package:cfpv/core/network/dio_client.dart';
import 'package:cfpv/features/orders/model/order_item_model.dart';
import 'package:cfpv/features/orders/model/order_model.dart';
import 'package:cfpv/features/orders/provider/order_provider.dart';
import 'package:cfpv/features/orders/repository/order_repository.dart';
import 'package:cfpv/features/orders/state/order_state.dart';

/// Mock repository that tracks internal state and can be configured to throw.
class _MockOrderRepository extends OrderRepository {
  final List<Order> _orders = [];
  bool _shouldThrow = false;
  int _nextId = 1;

  _MockOrderRepository()
      : super(dioClient: DioClient.create(baseUrl: 'http://test.local'));

  void setShouldThrow(bool value) {
    _shouldThrow = value;
  }

  void reset() {
    _orders.clear();
    _shouldThrow = false;
    _nextId = 1;
  }

  Order _createOrder({
    String? id,
    OrderStatus status = OrderStatus.pending,
    List<OrderItem>? items,
  }) {
    final orderItems = items ??
        [
          const OrderItem(
            id: 'item-1',
            productId: 'prod-1',
            productName: 'Product prod-1',
            unitPrice: 5.0,
            quantity: 2,
            totalPrice: 10.0,
          ),
        ];
    final now = DateTime.now();
    return Order(
      id: id ?? 'order-${_nextId++}',
      items: orderItems,
      status: status,
      subtotal: 10.0,
      tax: 1.0,
      total: 11.0,
      storeId: 'store-1',
      storeName: 'Test Store',
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<List<Order>> fetchOrders() async {
    if (_shouldThrow) throw Exception('Failed to fetch orders');
    return List.from(_orders);
  }

  @override
  Future<Order> placeOrder({
    List<Map<String, dynamic>>? items,
    String? storeId,
    String? notes,
  }) async {
    if (_shouldThrow) throw Exception('Failed to place order');
    final order = _createOrder();
    _orders.add(order);
    return order;
  }

  @override
  Future<Order> cancelOrder(String orderId) async {
    if (_shouldThrow) throw Exception('Failed to cancel order');
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) throw Exception('Order not found');
    final cancelled = _orders[index].copyWith(
      status: OrderStatus.cancelled,
      updatedAt: DateTime.now(),
    );
    _orders[index] = cancelled;
    return cancelled;
  }
}

void main() {
  late _MockOrderRepository mockRepo;
  late OrderNotifier notifier;

  setUp(() {
    mockRepo = _MockOrderRepository();
    notifier = OrderNotifier(mockRepo);
  });

  tearDown(() {
    mockRepo.reset();
    notifier.dispose();
  });

  group('OrderNotifier', () {
    testWidgets('starts with OrderStateInitial', (_) async {
      expect(notifier.state, isA<OrderStateInitial>());
      expect(notifier.state.isLoading, false);
      expect(notifier.state.hasError, false);
      expect(notifier.state.orders, isEmpty);
    });

    group('fetchOrders()', () {
      testWidgets('emits loaded with empty list when no orders',
          (tester) async {
        final future = notifier.fetchOrders();

        expect(notifier.state, isA<OrderStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<OrderStateLoaded>());
        expect((notifier.state as OrderStateLoaded).orders, isEmpty);
      });

      testWidgets('emits loaded with orders when they exist',
          (tester) async {
        // Pre-populate the mock repo
        await tester.runAsync(() => mockRepo.placeOrder());
        await tester.runAsync(() => mockRepo.placeOrder());

        final future = notifier.fetchOrders();

        expect(notifier.state, isA<OrderStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<OrderStateLoaded>());
        final orders = (notifier.state as OrderStateLoaded).orders;
        expect(orders.length, 2);
        expect(orders[0].status, OrderStatus.pending);
        expect(orders[1].status, OrderStatus.pending);
      });

      testWidgets('emits error on failure', (tester) async {
        mockRepo.setShouldThrow(true);

        final future = notifier.fetchOrders();

        expect(notifier.state, isA<OrderStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<OrderStateError>());
        expect(
          (notifier.state as OrderStateError).message,
          contains('Failed to fetch orders'),
        );
      });
    });

    group('placeOrder()', () {
      testWidgets('places order and reloads list on success',
          (tester) async {
        final future = notifier.placeOrder(
          items: [
            {'productId': 'prod-1', 'quantity': 2},
          ],
          storeId: 'store-1',
        );

        expect(notifier.state, isA<OrderStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<OrderStateLoaded>());
        final orders = (notifier.state as OrderStateLoaded).orders;
        expect(orders.length, 1);
        expect(orders[0].status, OrderStatus.pending);
        expect(orders[0].storeName, 'Test Store');
      });

      testWidgets('multiple orders accumulate', (tester) async {
        await tester.runAsync(() async {
          await notifier.placeOrder(storeId: 'store-1');
          await notifier.placeOrder(storeId: 'store-1');
          await notifier.placeOrder(storeId: 'store-1');
        });

        expect(notifier.state, isA<OrderStateLoaded>());
        expect(
            (notifier.state as OrderStateLoaded).orders.length, 3,);
      });

      testWidgets('emits error on failure', (tester) async {
        mockRepo.setShouldThrow(true);

        final future = notifier.placeOrder(storeId: 'store-1');

        expect(notifier.state, isA<OrderStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<OrderStateError>());
        expect(
          (notifier.state as OrderStateError).message,
          contains('Failed to place order'),
        );
      });
    });

    group('cancelOrder()', () {
      testWidgets('cancels order and reloads list on success',
          (tester) async {
        // Pre-populate with an order
        await tester.runAsync(
            () => notifier.placeOrder(storeId: 'store-1'),);

        final orderId =
            (notifier.state as OrderStateLoaded).orders[0].id;

        final future = notifier.cancelOrder(orderId);

        expect(notifier.state, isA<OrderStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<OrderStateLoaded>());
        final orders = (notifier.state as OrderStateLoaded).orders;
        expect(orders.length, 1);
        expect(orders[0].status, OrderStatus.cancelled);
      });

      testWidgets('emits error on failure', (tester) async {
        mockRepo.setShouldThrow(true);

        final future = notifier.cancelOrder('nonexistent');

        expect(notifier.state, isA<OrderStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<OrderStateError>());
        expect(
          (notifier.state as OrderStateError).message,
          contains('Failed to cancel order'),
        );
      });
    });
  });
}
