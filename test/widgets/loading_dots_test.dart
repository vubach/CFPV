import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cfpv/shared/widgets/feedback/loading_dots.dart';

void main() {
  group('LoadingDots', () {
    testWidgets('renders three circular dot containers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingDots(),
          ),
        ),
      );

      // LoadingDots creates 3 circular dot containers (8x8, circle shape)
      final dots = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.constraints?.maxWidth == 8 &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(dots, findsNWidgets(3));
    });

    testWidgets('renders with custom color', (tester) async {
      const customColor = Color(0xFFFF0000);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingDots(color: customColor),
          ),
        ),
      );

      // Verify the three dot containers use the custom color
      final dots = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.constraints?.maxWidth == 8 &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == customColor,
      );
      expect(dots, findsNWidgets(3));
    });

    testWidgets('animates without throwing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingDots(),
          ),
        ),
      );

      // Advance through several animation frames
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // No errors should occur during animation
      expect(tester.takeException(), isNull);
    });
  });
}
