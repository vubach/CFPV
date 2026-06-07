import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cfpv/shared/theme/colors.dart';
import 'package:cfpv/shared/theme/spacing.dart';
import 'package:cfpv/shared/widgets/cards/item_row.dart';

Widget _wrap(Widget w) => MaterialApp(home: Scaffold(body: w));

/// Matches the quantity badge Container (28x28, borderRadius: 6).
Finder _badgeContainer() => find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).borderRadius ==
              BorderRadius.circular(6),
    );

void main() {
  group('ItemRow — quantityBadge variant', () {
    testWidgets('renders product name, subtitle, and total price',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ItemRow(
          quantity: 3,
          productName: 'Caffe Latte',
          subtitle: r'$5.50 each',
          totalPrice: r'$16.50',
        ),
      ));

      expect(find.text('Caffe Latte'), findsOneWidget);
      expect(find.text(r'$5.50 each'), findsOneWidget);
      expect(find.text(r'$16.50'), findsOneWidget);
    });

    testWidgets('renders quantity badge with correct count', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItemRow(
          quantity: 3,
          productName: 'Latte',
          subtitle: r'$5.00 each',
          totalPrice: r'$15.00',
        ),
      ));

      expect(find.text('3'), findsOneWidget);
      expect(_badgeContainer(), findsOneWidget);
    });

    testWidgets('no leading widget when quantity is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItemRow(
          productName: 'Latte',
          subtitle: r'$5.00 each',
          totalPrice: r'$15.00',
        ),
      ));

      expect(_badgeContainer(), findsNothing);
      expect(find.text('Latte'), findsOneWidget);
      expect(find.text(r'$15.00'), findsOneWidget);
    });
  });

  group('ItemRow — imagePlaceholder variant', () {
    testWidgets('renders with custom leading and starbucksGreen total price',
        (tester) async {
      await tester.pumpWidget(_wrap(
        ItemRow(
          leading: ItemRow.imagePlaceholder(),
          productName: 'Iced Coffee',
          subtitle: 'Qty: 1 \u00d7 \$3.75',
          totalPrice: r'$3.75',
          totalPriceColor: CFPVColors.starbucksGreen,
        ),
      ));

      expect(find.text('Iced Coffee'), findsOneWidget);
      expect(find.text('Qty: 1 \u00d7 \$3.75'), findsOneWidget);
      expect(find.text(r'$3.75'), findsOneWidget);
    });

    testWidgets('renders coffee icon in image placeholder', (tester) async {
      await tester.pumpWidget(_wrap(
        ItemRow(
          leading: ItemRow.imagePlaceholder(),
          productName: 'Latte',
          subtitle: 'Qty: 2 \u00d7 \$5.00',
          totalPrice: r'$10.00',
        ),
      ));

      expect(find.byIcon(Icons.local_cafe_outlined), findsOneWidget);
    });

    testWidgets('truncates long product name with maxLines: 1',
        (tester) async {
      const longName =
          'Signature Vanilla Bean Coconut Milk Latte with Extra Shot';

      await tester.pumpWidget(_wrap(
        ItemRow(
          leading: ItemRow.imagePlaceholder(),
          productName: longName,
          productNameMaxLines: 1,
          productNameOverflow: TextOverflow.ellipsis,
          subtitle: 'Qty: 1 \u00d7 \$6.50',
          totalPrice: r'$6.50',
        ),
      ));

      final textWidget = tester.widget<Text>(
        find.byWidgetPredicate(
          (w) => w is Text && w.data == longName,
        ),
      );
      expect(textWidget.maxLines, 1);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('renders subtitle with gap when subtitleGap > 0',
        (tester) async {
      await tester.pumpWidget(_wrap(
        ItemRow(
          leading: ItemRow.imagePlaceholder(),
          productName: 'Latte',
          subtitle: 'Qty: 2 \u00d7 \$5.00',
          subtitleGap: 2,
          totalPrice: r'$10.00',
        ),
      ));

      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.height == 2,
        ),
        findsOneWidget,
      );
    });
  });

  group('ItemRow — leadingGap', () {
    testWidgets('uses default leadingGap of CFPVSpacing.space2',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ItemRow(
          quantity: 1,
          productName: 'Latte',
          subtitle: r'$5.00 each',
          totalPrice: r'$5.00',
        ),
      ));

      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == CFPVSpacing.space2,
        ),
        findsOneWidget,
      );
    });

    testWidgets('accepts custom leadingGap', (tester) async {
      await tester.pumpWidget(_wrap(
        ItemRow(
          leading: ItemRow.imagePlaceholder(),
          leadingGap: CFPVSpacing.space3,
          productName: 'Latte',
          subtitle: 'Qty: 1 \u00d7 \$5.00',
          totalPrice: r'$5.00',
        ),
      ));

      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == CFPVSpacing.space3,
        ),
        findsOneWidget,
      );
    });
  });

  group('ItemRow — totalPriceColor', () {
    testWidgets('defaults to CFPVColors.textBlack', (tester) async {
      await tester.pumpWidget(_wrap(
        const ItemRow(
          quantity: 1,
          productName: 'Latte',
          subtitle: r'$5.00 each',
          totalPrice: r'$5.00',
        ),
      ));

      final textWidget = tester.widget<Text>(
        find.byWidgetPredicate(
          (w) => w is Text && w.data == r'$5.00',
        ),
      );
      expect(textWidget.style!.color, CFPVColors.textBlack);
    });

    testWidgets('applies custom totalPriceColor', (tester) async {
      await tester.pumpWidget(_wrap(
        ItemRow(
          leading: ItemRow.imagePlaceholder(),
          productName: 'Latte',
          subtitle: 'Qty: 1 \u00d7 \$5.00',
          totalPrice: r'$5.00',
          totalPriceColor: CFPVColors.starbucksGreen,
        ),
      ));

      final textWidget = tester.widget<Text>(
        find.byWidgetPredicate(
          (w) => w is Text && w.data == r'$5.00',
        ),
      );
      expect(textWidget.style!.color, CFPVColors.starbucksGreen);
    });
  });

  group('ItemRow — static helpers', () {
    testWidgets('quantityBadge renders count and has correct decoration',
        (tester) async {
      await tester.pumpWidget(_wrap(
        ItemRow.quantityBadge(5),
      ));

      expect(find.text('5'), findsOneWidget);
      expect(_badgeContainer(), findsOneWidget);
    });

    testWidgets('imagePlaceholder renders coffee icon', (tester) async {
      await tester.pumpWidget(_wrap(
        ItemRow.imagePlaceholder(),
      ));

      expect(find.byIcon(Icons.local_cafe_outlined), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).color == CFPVColors.neutralCool,
        ),
        findsOneWidget,
      );
    });
  });
}
