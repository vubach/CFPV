import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cfpv/shared/widgets/buttons/outlined_pill_button.dart';

void main() {
  group('OutlinedPillButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OutlinedPillButton(
              label: 'Cancel',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('fires onPressed when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OutlinedPillButton(
              label: 'Retry',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      expect(tapped, isTrue);
    });

    testWidgets('does not fire onPressed when onPressed is null',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OutlinedPillButton(
              label: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));
      expect(tapped, isFalse);
    });

    testWidgets('applies custom text and border colors', (tester) async {
      const customColor = Color(0xFFFF0000);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OutlinedPillButton(
              label: 'Delete',
              onPressed: () {},
              textColor: customColor,
              borderColor: customColor,
            ),
          ),
        ),
      );

      final button =
          tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final style = button.style;

      // Verify custom foreground color
      final foregroundColor =
          style?.foregroundColor?.resolve(<MaterialState>{});
      expect(foregroundColor, customColor);

      // Verify custom border color
      final side = style?.side?.resolve(<MaterialState>{});
      expect(side?.color, customColor);
    });

    testWidgets('renders with full width when width is double.infinity',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OutlinedPillButton(
              label: 'Wide',
              onPressed: () {},
              width: double.infinity,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == double.infinity,
        ),
      );
      expect(sizedBox.width, double.infinity);
    });
  });
}
