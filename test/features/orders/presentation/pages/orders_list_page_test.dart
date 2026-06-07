import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cfpv/core/network/dio_client.dart';
import 'package:cfpv/features/orders/model/order_item_model.dart';
import 'package:cfpv/features/orders/model/order_model.dart';
import 'package:cfpv/features/orders/presentation/pages/orders_list_page.dart';
import 'package:cfpv/features/orders/provider/order_provider.dart';
import 'package:cfpv/features/orders/repository/order_repository.dart';

/// Mock repository with configurable behavior for page-level tests.
class _MockOrderRepository extends OrderRepository {
  bool _shouldThrow = false;
  bool _returnEmpty = false;
  Completer<List<Order>>? _fetchCompleter;

  _MockOrderRepository()
      : super(dioClient: DioClient.create(baseUrl: 'http://test.local'));

  void setShouldThrow(bool value) => _shouldThrow = value;
  void setReturnEmpty(bool value) => _returnEmpty = value;

  /// Hold the next fetchOrders call until [completeFetch] is called.
  void holdNextFetch() {
    _fetchCompleter = Completer<List<Order>>();
  }

  /// Complete a held fetch so it resolves.
  void completeFetch() {
    _fetchCompleter?.complete(
      _orders(),
    );
    _fetchCompleter = null;
  }

  List<Order> _orders() {
    if (_returnEmpty) return [];
    return [
      Order(
        id: 'order-1',
        items: const [
          OrderItem(
            id: 'item-1',
            productId: 'prod-1',
            productName: 'Cold Brew',
            unitPrice: 4.50,
            quantity: 1,
            totalPrice: 4.50,
          ),
        ],
        status: OrderStatus.pending,
        subtotal: 4.50,
        total: 4.50,
        storeName: 'Main St Café',
        createdAt: DateTime(2026, 6, 7, 10, 0),
      ),
    ];
  }

  @override
  Future<List<Order>> fetchOrders() async {
    if (_shouldThrow) throw Exception('Network error');
    if (_fetchCompleter != null) {
      return _fetchCompleter!.future;
    }
    return _orders();
  }
}

ProviderContainer _createContainer(_MockOrderRepository repo) {
  return ProviderContainer(
    overrides: [
      orderProvider.overrideWith((_) => OrderNotifier(repo)),
    ],
  );
}

Widget _createApp(ProviderContainer container) {
  return MaterialApp(
    home: ProviderScope(
      parent: container,
      child: const OrdersListPage(),
    ),
  );
}

void main() {
  group('OrdersListPage', () {
    testWidgets('shows loading indicator then order list', (tester) async {
      final repo = _MockOrderRepository();
      repo.holdNextFetch(); // Prevent fetch from resolving immediately
      final container = _createContainer(repo);

      await tester.pumpWidget(_createApp(container));
      await tester.pump(); // Post-frame callback fires, fetchOrders sets loading
      await tester.pump(); // Rebuild widget tree to show loading indicator

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the fetch
      repo.completeFetch();
      await tester.pumpAndSettle();

      // Should show the order list
      expect(find.text('Order History'), findsOneWidget);
      expect(find.text('Main St Café'), findsOneWidget);
      expect(find.text('Cold Brew'), findsOneWidget);
    });

    testWidgets('shows empty state when no orders', (tester) async {
      final repo = _MockOrderRepository();
      repo.setReturnEmpty(true);
      final container = _createContainer(repo);

      await tester.pumpWidget(_createApp(container));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('No orders yet'), findsOneWidget);
      expect(
        find.text('Place your first order and it will appear here.'),
        findsOneWidget,
      );
    });

    testWidgets('shows error state with retry button', (tester) async {
      final repo = _MockOrderRepository();
      repo.setShouldThrow(true);
      final container = _createContainer(repo);

      await tester.pumpWidget(_createApp(container));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Could not load orders'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      // Tap retry — still throws, should stay in error
      await tester.tap(find.text('Try Again'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Could not load orders'), findsOneWidget);
    });

    testWidgets('shows initial state briefly before loading',
        (tester) async {
      final repo = _MockOrderRepository();
      final notifier = OrderNotifier(repo);
      final container = ProviderContainer(
        overrides: [
          orderProvider.overrideWith((_) => notifier),
        ],
      );

      await tester.pumpWidget(_createApp(container));

      // Before the post-frame callback fires, state is initial
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pump(); // triggers post-frame callback
      await tester.pumpAndSettle();

      expect(find.text('Main St Café'), findsOneWidget);
    });
  });
}
