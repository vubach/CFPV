import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/radius.dart';
import '../../theme/spacing.dart';

/// Outlined pill button — Green Accent border, transparent fill.
/// DESIGN.md §9.1: Primary Outlined (Green)
class OutlinedPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? textColor;
  final Color? borderColor;
  final double? width;

  const OutlinedPillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.textColor,
    this.borderColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? CFPVColors.greenAccent,
          side: BorderSide(color: borderColor ?? CFPVColors.greenAccent),
          padding: const EdgeInsets.symmetric(
            horizontal: CFPVSpacing.space4,
            vertical: CFPVSpacing.space3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CFPVRadius.button),
          ),
        ),
        child: Text(
          label,
          style: CFPVTypography.buttonLabel.copyWith(
            color: textColor ?? CFPVColors.greenAccent,
          ),
        ),
      ),
    );
  }
}
