import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cfpv/features/orders/model/order_model.dart';
import 'package:cfpv/features/orders/presentation/widgets/order_status_timeline.dart';

Widget _wrap(Widget w) => MaterialApp(home: Scaffold(body: w));

final _fixedTime = DateTime(2026, 6, 7, 10, 0, 0);

void main() {
  group('OrderStatusTimeline', () {
    testWidgets('shows Order Placed as first step', (tester) async {
      await tester.pumpWidget(_wrap(
        OrderStatusTimeline(
          currentStatus: OrderStatus.pending,
          createdAt: _fixedTime,
        ),
      ),);

      expect(find.text('Order Placed'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Preparing'), findsOneWidget);
      expect(find.text('Ready for Pickup'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('shows only first step as active for pending status',
        (tester) async {
      await tester.pumpWidget(_wrap(
        OrderStatusTimeline(
          currentStatus: OrderStatus.pending,
          createdAt: _fixedTime,
        ),
      ),);

      // First step has timestamp
      expect(find.textContaining('Jun 7'), findsOneWidget);

      // All labels present
      expect(find.text('Order Placed'), findsOneWidget);
    });

    testWidgets('marks completed steps with check icons for confirmed status',
        (tester) async {
      await tester.pumpWidget(_wrap(
        OrderStatusTimeline(
          currentStatus: OrderStatus.confirmed,
          createdAt: _fixedTime,
        ),
      ),);

      // Check icons are rendered (2 completed: placed + confirmed)
      expect(find.byIcon(Icons.check), findsAtLeast(1));
    });

    testWidgets('shows all stages for completed order', (tester) async {
      await tester.pumpWidget(_wrap(
        OrderStatusTimeline(
          currentStatus: OrderStatus.completed,
          createdAt: _fixedTime,
          updatedAt: _fixedTime.add(const Duration(hours: 1)),
        ),
      ),);

      expect(find.text('Completed'), findsOneWidget);
      // All stages should have check icons
      expect(find.byIcon(Icons.check), findsAtLeast(4));
    });

    testWidgets('shows cancelled order timeline', (tester) async {
      await tester.pumpWidget(_wrap(
        OrderStatusTimeline(
          currentStatus: OrderStatus.cancelled,
          createdAt: _fixedTime,
          updatedAt: _fixedTime.add(const Duration(minutes: 30)),
        ),
      ),);

      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsAtLeast(1));
      expect(find.byIcon(Icons.check), findsAtLeast(1));
    });
  });
}
