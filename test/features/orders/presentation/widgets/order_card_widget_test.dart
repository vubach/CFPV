import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cfpv/features/orders/model/order_item_model.dart';
import 'package:cfpv/features/orders/model/order_model.dart';
import 'package:cfpv/features/orders/presentation/widgets/order_card_widget.dart';

Widget _wrap(Widget w) => MaterialApp(home: Scaffold(body: w));

final _fixedCreatedAt = DateTime(2026, 6, 7, 10, 0, 0);

Order _sampleOrder({
  String id = 'order-1',
  OrderStatus status = OrderStatus.pending,
  List<OrderItem>? items,
  DateTime? createdAt,
}) {
  final orderItems = items ??
      [
        const OrderItem(
          id: 'item-1',
          productId: 'prod-1',
          productName: 'Caffè Latte',
          unitPrice: 5.50,
          quantity: 2,
          totalPrice: 11.00,
        ),
      ];
  return Order(
    id: id,
    items: orderItems,
    status: status,
    subtotal: 11.00,
    tax: 1.10,
    total: 12.10,
    storeId: 'store-1',
    storeName: 'Downtown Café',
    createdAt: createdAt ?? _fixedCreatedAt,
  );
}

void main() {
  group('OrderCard', () {
    testWidgets('displays store name and relative date', (tester) async {
      await tester.pumpWidget(_wrap(
        OrderCard(order: _sampleOrder()),
      ),);

      expect(find.text('Downtown Café'), findsOneWidget);
      // Relative date formatting produces "Xh ago" — robust against exact hour drift
      expect(find.textContaining(' ago'), findsOneWidget);
    });

    testWidgets('displays item summary for single item', (tester) async {
      await tester.pumpWidget(_wrap(
        OrderCard(order: _sampleOrder()),
      ),);

      expect(find.text('Caffè Latte'), findsOneWidget);
    });

    testWidgets('displays item summary with +more for 3+ items',
        (tester) async {
      final order = _sampleOrder(items: [
        const OrderItem(
          id: 'item-1', productId: 'p1', productName: 'Latte',
          unitPrice: 5.0, quantity: 1, totalPrice: 5.0,
        ),
        const OrderItem(
          id: 'item-2', productId: 'p2', productName: 'Mocha',
          unitPrice: 6.0, quantity: 1, totalPrice: 6.0,
        ),
        const OrderItem(
          id: 'item-3', productId: 'p3', productName: 'Cold Brew',
          unitPrice: 4.5, quantity: 1, totalPrice: 4.5,
        ),
      ],);

      await tester.pumpWidget(_wrap(OrderCard(order: order)));

      expect(find.textContaining('Latte'), findsOneWidget);
      expect(find.textContaining('Mocha'), findsOneWidget);
      expect(find.textContaining('+1 more'), findsOneWidget);
    });

    testWidgets('displays total price formatted', (tester) async {
      await tester.pumpWidget(_wrap(
        OrderCard(order: _sampleOrder()),
      ),);

      expect(find.text('\$12.10'), findsOneWidget);
    });

    testWidgets('displays status badge', (tester) async {
      await tester.pumpWidget(_wrap(
        OrderCard(order: _sampleOrder(status: OrderStatus.confirmed)),
      ),);

      expect(find.text('Confirmed'), findsOneWidget);
    });

    testWidgets('fires onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(
        OrderCard(
          order: _sampleOrder(),
          onTap: () => tapped = true,
        ),
      ),);

      await tester.tap(find.text('Downtown Café'));
      expect(tapped, isTrue);
    });
  });
}
