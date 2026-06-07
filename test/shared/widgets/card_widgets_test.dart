import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cfpv/shared/theme/colors.dart';
import 'package:cfpv/shared/theme/radius.dart';
import 'package:cfpv/shared/theme/spacing.dart';
import 'package:cfpv/shared/widgets/cards/card_container.dart';
import 'package:cfpv/shared/widgets/cards/notes_card.dart';

Widget _wrap(Widget w) => MaterialApp(home: Scaffold(body: w));

/// Finds the root Container built by CardContainer — identified by wrapping
/// the child Text widget and having a BoxDecoration.
Finder _cardContainerOf(String childText) => find.ancestor(
      of: find.text(childText),
      matching: find.byWidgetPredicate(
        (w) => w is Container && w.decoration is BoxDecoration,
      ),
    ).first;

void main() {
  // ── CardContainer ────────────────────────────────────────────

  group('CardContainer', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(_wrap(
        const CardContainer(
          child: Text('Hello'),
        ),
      ));

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('applies white background color', (tester) async {
      await tester.pumpWidget(_wrap(
        const CardContainer(
          child: Text('Content'),
        ),
      ));

      final container = tester.widget<Container>(_cardContainerOf('Content'));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, CFPVColors.white);
    });

    testWidgets('applies CFPVRadius.card border radius', (tester) async {
      await tester.pumpWidget(_wrap(
        const CardContainer(
          child: Text('Content'),
        ),
      ));

      final container = tester.widget<Container>(_cardContainerOf('Content'));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(CFPVRadius.card));
    });

    testWidgets('applies default CFPVSpacing.space4 padding',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const CardContainer(
          child: Text('Content'),
        ),
      ));

      final container = tester.widget<Container>(_cardContainerOf('Content'));
      expect(container.padding, const EdgeInsets.all(CFPVSpacing.space4));
    });

    testWidgets('accepts custom padding override', (tester) async {
      await tester.pumpWidget(_wrap(
        const CardContainer(
          padding: EdgeInsets.all(8),
          child: Text('Content'),
        ),
      ));

      final container = tester.widget<Container>(_cardContainerOf('Content'));
      expect(container.padding, const EdgeInsets.all(8));
    });

    testWidgets('includes box shadow decoration', (tester) async {
      await tester.pumpWidget(_wrap(
        const CardContainer(
          child: Text('Content'),
        ),
      ));

      final container = tester.widget<Container>(_cardContainerOf('Content'));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, greaterThan(0));
    });
  });

  // ── NotesCard ────────────────────────────────────────────────

  group('NotesCard', () {
    testWidgets('renders notes text', (tester) async {
      await tester.pumpWidget(_wrap(
        const NotesCard(notes: 'Please add extra napkins.'),
      ));

      expect(find.text('Please add extra napkins.'), findsOneWidget);
    });

    testWidgets('renders default title "Order Notes"', (tester) async {
      await tester.pumpWidget(_wrap(
        const NotesCard(notes: 'Handle with care.'),
      ));

      expect(find.text('Order Notes'), findsOneWidget);
    });

    testWidgets('renders custom title', (tester) async {
      await tester.pumpWidget(_wrap(
        const NotesCard(
          title: 'Special Instructions',
          notes: 'No ice, please.',
        ),
      ));

      expect(find.text('Special Instructions'), findsOneWidget);
      expect(find.text('No ice, please.'), findsOneWidget);
    });

    testWidgets('uses CardContainer internally', (tester) async {
      await tester.pumpWidget(_wrap(
        const NotesCard(notes: 'Test notes'),
      ));

      expect(find.byType(CardContainer), findsOneWidget);
    });

    testWidgets('header uses smallBold weight', (tester) async {
      await tester.pumpWidget(_wrap(
        const NotesCard(notes: 'Test notes'),
      ));

      final headerText = tester.widget<Text>(find.text('Order Notes'));
      // smallBold is a semi-bold weight
      expect(headerText.style!.fontWeight, FontWeight.w600);
    });

    testWidgets('notes body uses regular weight', (tester) async {
      await tester.pumpWidget(_wrap(
        const NotesCard(notes: 'Test notes body'),
      ));

      final bodyText = tester.widget<Text>(find.text('Test notes body'));
      expect(bodyText.style!.fontWeight, FontWeight.w400);
    });
  });
}
