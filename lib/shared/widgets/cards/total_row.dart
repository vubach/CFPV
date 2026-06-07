import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// A label-value row used for subtotal, tax, and total displays.
/// The [value] is a pre-formatted string (e.g. "\$4.50").
/// Set [isBold] or provide a [valueStyle] to customize the value text.
class TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final TextStyle? valueStyle;

  const TotalRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveValueStyle = valueStyle ??
        CFPVTypography.body.copyWith(
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          color: isBold
              ? CFPVColors.textBlack
              : CFPVColors.textBlackSoft,
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: CFPVTypography.body.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold
                ? CFPVColors.textBlack
                : CFPVColors.textBlackSoft,
          ),
        ),
        Text(value, style: effectiveValueStyle),
      ],
    );
  }
}
