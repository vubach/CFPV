import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cfpv/shared/widgets/buttons/primary_pill_button.dart';

void main() {
  group('PrimaryPillButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryPillButton(
              label: 'Sign In',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('fires onPressed when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryPillButton(
              label: 'Submit',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Submit'));
      expect(tapped, isTrue);
    });

    testWidgets('shows loading spinner when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryPillButton(
              label: 'Loading...',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Should show a CircularProgressIndicator when loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Should not show the label text when loading
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('disables button and does not fire onPressed when isLoading',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryPillButton(
              label: 'Save',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      // Tap the loading spinner area
      await tester.tap(find.byType(CircularProgressIndicator));
      expect(tapped, isFalse);
    });

    testWidgets('does not fire onPressed when onPressed is null',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrimaryPillButton(
              label: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      // Attempt to tap the button
      await tester.tap(find.text('Disabled'));
      expect(tapped, isFalse);
    });

    testWidgets('renders full width with fullWidth factory', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryPillButton.fullWidth(
              label: 'Full Width',
              onPressed: () {},
            ),
          ),
        ),
      );

      // The button should be wrapped in a SizedBox with infinite width
      final sizedBox = tester.widget<SizedBox>(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == double.infinity,
        ),
      );
      expect(sizedBox.width, double.infinity);
      expect(find.text('Full Width'), findsOneWidget);
    });

    testWidgets('renders with correct green accent color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryPillButton(
              label: 'Order',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style;

      // Verify the button uses the green accent background
      final backgroundColor =
          style?.backgroundColor?.resolve(<WidgetState>{});
      expect(backgroundColor, const Color(0xFF00754A));
    });
  });
}
