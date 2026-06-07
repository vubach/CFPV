import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cfpv/core/network/dio_client.dart';
import 'package:cfpv/features/orders/model/order_item_model.dart';
import 'package:cfpv/features/orders/model/order_model.dart';
import 'package:cfpv/features/orders/presentation/pages/order_detail_page.dart';
import 'package:cfpv/features/orders/provider/order_provider.dart';
import 'package:cfpv/features/orders/repository/order_repository.dart';
import 'package:cfpv/features/orders/state/order_state.dart';

class _MockOrderRepository extends OrderRepository {
  _MockOrderRepository()
      : super(dioClient: DioClient.create(baseUrl: 'http://test.local'));

  @override
  Future<List<Order>> fetchOrders() async {
    return [
      Order(
        id: 'order-1',
        items: const [
          OrderItem(
            id: 'item-1',
            productId: 'prod-1',
            productName: 'Caffè Latte',
            unitPrice: 5.50,
            quantity: 2,
            totalPrice: 11.00,
          ),
          OrderItem(
            id: 'item-2',
            productId: 'prod-2',
            productName: 'Cold Brew',
            unitPrice: 4.50,
            quantity: 1,
            totalPrice: 4.50,
          ),
        ],
        status: OrderStatus.pending,
        subtotal: 15.50,
        tax: 1.55,
        total: 17.05,
        storeName: 'Downtown Café',
        notes: 'Extra hot, please',
        createdAt: DateTime(2026, 6, 7, 10, 0),
      ),
    ];
  }

  @override
  Future<Order> reorderOrder(String orderId) async {
    return Order(
      id: 'order-new',
      items: const [],
      status: OrderStatus.pending,
      subtotal: 0.0,
      tax: 0.0,
      total: 0.0,
      storeId: 'store-1',
      createdAt: DateTime.now(),
    );
  }
}

/// A mock repo that fails on reorder (for error path testing).
class _FailingReorderRepository extends OrderRepository {
  _FailingReorderRepository()
      : super(dioClient: DioClient.create(baseUrl: 'http://test.local'));

  @override
  Future<List<Order>> fetchOrders() async {
    return [
      Order(
        id: 'order-1',
        items: const [],
        status: OrderStatus.completed,
        subtotal: 11.00,
        tax: 0.88,
        total: 11.88,
        storeName: 'Downtown Café',
        createdAt: DateTime(2026, 6, 7, 10, 0),
      ),
    ];
  }

  @override
  Future<Order> reorderOrder(String orderId) async {
    throw Exception('Reorder failed - item unavailable');
  }
}

/// Build a test app with GoRouter support.
Widget _buildApp(Order order, OrderRepository repo) {
  final notifier = OrderNotifier(repo);
  notifier.state = OrderStateLoaded([order]);

  final goRouter = GoRouter(
    initialLocation: '/profile/orders/order-1',
    routes: [
      GoRoute(
        path: '/profile/orders/:orderId',
        name: 'profileOrderDetail',
        builder: (_, state) {
          final oid = state.pathParameters['orderId']!;
          return OrderDetailPage(orderId: oid);
        },
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('Cart Page'))),
      ),
    ],
  );

  final container = ProviderContainer(
    overrides: [
      orderProvider.overrideWith((_) => notifier),
    ],
  );

  return ProviderScope(
    parent: container,
    child: MaterialApp.router(
      routerConfig: goRouter,
    ),
  );
}

/// Helper: create a pending order.
Order _pendingOrder() => Order(
      id: 'order-1',
      items: const [
        OrderItem(
          id: 'item-1',
          productId: 'prod-1',
          productName: 'Caffè Latte',
          unitPrice: 5.50,
          quantity: 2,
          totalPrice: 11.00,
        ),
        OrderItem(
          id: 'item-2',
          productId: 'prod-2',
          productName: 'Cold Brew',
          unitPrice: 4.50,
          quantity: 1,
          totalPrice: 4.50,
        ),
      ],
      status: OrderStatus.pending,
      subtotal: 15.50,
      tax: 1.55,
      total: 17.05,
      storeName: 'Downtown Café',
      notes: 'Extra hot, please',
      createdAt: DateTime(2026, 6, 7, 10, 0),
    );

/// Helper: create a completed order.
Order _completedOrder() => Order(
      id: 'order-1',
      items: const [
        OrderItem(
          id: 'item-1',
          productId: 'prod-1',
          productName: 'Caffè Latte',
          unitPrice: 5.50,
          quantity: 2,
          totalPrice: 11.00,
        ),
      ],
      status: OrderStatus.completed,
      subtotal: 11.00,
      tax: 0.88,
      total: 11.88,
      storeName: 'Downtown Café',
      createdAt: DateTime(2026, 6, 7, 10, 0),
      updatedAt: DateTime(2026, 6, 7, 10, 15),
    );

void main() {
  group('OrderDetailPage', () {
    // ── Existing state tests ──────────────────────

    testWidgets('shows store name and order ID', (tester) async {
      final repo = _MockOrderRepository();
      await tester.pumpWidget(_buildApp(_pendingOrder(), repo));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Downtown Café'), findsOneWidget);
      expect(find.text('#order-1'), findsOneWidget);
      expect(find.text('Order Details'), findsOneWidget);
    });

    testWidgets('shows order items with quantities and prices',
        (tester) async {
      final repo = _MockOrderRepository();
      await tester.pumpWidget(_buildApp(_pendingOrder(), repo));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Caffè Latte'), findsOneWidget);
      expect(find.text('Cold Brew'), findsOneWidget);
      expect(find.text('\$11.00'), findsOneWidget);
      expect(find.text('\$4.50'), findsOneWidget);
    });

    testWidgets('shows subtotal, tax, and total', (tester) async {
      final repo = _MockOrderRepository();
      await tester.pumpWidget(_buildApp(_pendingOrder(), repo));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('Tax'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('\$15.50'), findsOneWidget);
      expect(find.text('\$17.05'), findsOneWidget);
    });

    testWidgets('shows order notes when present', (tester) async {
      final repo = _MockOrderRepository();
      await tester.pumpWidget(_buildApp(_pendingOrder(), repo));
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Order Notes'), findsOneWidget);
      expect(find.text('Extra hot, please'), findsOneWidget);
    });

    testWidgets('shows cancel button for active (pending) order',
        (tester) async {
      final repo = _MockOrderRepository();
      await tester.pumpWidget(_buildApp(_pendingOrder(), repo));
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('Cancel Order'), findsOneWidget);
    });

    testWidgets('shows order not found for missing order ID',
        (tester) async {
      final repo = _MockOrderRepository();
      final notifier = OrderNotifier(repo);
      notifier.state = const OrderStateLoaded([]);
      final goRouter = GoRouter(
        initialLocation: '/profile/orders/nonexistent',
        routes: [
          GoRoute(
            path: '/profile/orders/:orderId',
            builder: (_, state) {
              final oid = state.pathParameters['orderId']!;
              return OrderDetailPage(orderId: oid);
            },
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [orderProvider.overrideWith((_) => notifier)],
      );
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp.router(routerConfig: goRouter),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Order not found'), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);
    });

    testWidgets('shows status timeline on the page', (tester) async {
      final repo = _MockOrderRepository();
      await tester.pumpWidget(_buildApp(_pendingOrder(), repo));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Order Status'), findsOneWidget);
      expect(find.text('Order Placed'), findsOneWidget);
    });

    // ── Reorder tests ────────────────────────────

    testWidgets('shows Reorder button for completed orders',
        (tester) async {
      final repo = _MockOrderRepository();
      await tester.pumpWidget(_buildApp(_completedOrder(), repo));
      await tester.pump();
      await tester.pumpAndSettle();

      // Scroll to the bottom where the Reorder button is
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      expect(find.text('Reorder'), findsOneWidget);
    });

    testWidgets('does not show Cancel button when Reorder is shown',
        (tester) async {
      final repo = _MockOrderRepository();
      await tester.pumpWidget(_buildApp(_completedOrder(), repo));
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      expect(find.text('Reorder'), findsOneWidget);
      expect(find.text('Cancel Order'), findsNothing);
    });

    testWidgets('reorder shows success snackbar on success',
        (tester) async {
      final repo = _MockOrderRepository();
      await tester.pumpWidget(_buildApp(_completedOrder(), repo));
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reorder'));
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();

      // After successful reorder + state check, success snackbar should show
      expect(find.text('Items added to your cart'), findsOneWidget);
    });

    testWidgets('reorder shows error snackbar on failure',
        (tester) async {
      final repo = _FailingReorderRepository();
      await tester.pumpWidget(_buildApp(_completedOrder(), repo));
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reorder'));
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();

      // OrderNotifier catches the error internally and sets OrderStateError,
      // then the page checks for it and shows error snackbar
      expect(find.textContaining('Failed to reorder'), findsOneWidget);
    });
  });
}
