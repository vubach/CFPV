import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cfpv/features/orders/model/order_model.dart';
import 'package:cfpv/features/orders/presentation/widgets/order_status_badge.dart';

Widget _wrap(Widget w) => MaterialApp(home: Scaffold(body: w));

void main() {
  group('OrderStatusBadge', () {
    testWidgets('renders Pending status with schedule icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const OrderStatusBadge(status: OrderStatus.pending),
      ),);

      expect(find.text('Pending'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('renders Confirmed status with check_circle_outline icon',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const OrderStatusBadge(status: OrderStatus.confirmed),
      ),);

      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('renders Preparing status with coffee_maker icon',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const OrderStatusBadge(status: OrderStatus.preparing),
      ),);

      expect(find.text('Preparing'), findsOneWidget);
      expect(find.byIcon(Icons.coffee_maker), findsOneWidget);
    });

    testWidgets('renders Ready status with local_cafe icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const OrderStatusBadge(status: OrderStatus.ready),
      ),);

      expect(find.text('Ready'), findsOneWidget);
      expect(find.byIcon(Icons.local_cafe), findsOneWidget);
    });

    testWidgets('renders Completed status with check_circle icon',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const OrderStatusBadge(status: OrderStatus.completed),
      ),);

      expect(find.text('Completed'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('renders Cancelled status with cancel_outlined icon',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const OrderStatusBadge(status: OrderStatus.cancelled),
      ),);

      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    });
  });
}
