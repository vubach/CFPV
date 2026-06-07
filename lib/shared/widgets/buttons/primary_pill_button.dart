import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/radius.dart';
import '../../theme/spacing.dart';

/// Primary filled pill button — Green Accent (#00754A).
/// DESIGN.md §9.1: Primary Filled (Green Accent)
class PrimaryPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;

  const PrimaryPillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
  });

  factory PrimaryPillButton.fullWidth({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return PrimaryPillButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      width: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: CFPVColors.greenAccent,
          foregroundColor: CFPVColors.white,
          disabledBackgroundColor: CFPVColors.greenAccent.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(
            horizontal: CFPVSpacing.space4,
            vertical: CFPVSpacing.space3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CFPVRadius.button),
          ),
          elevation: 0,
        ),
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(CFPVColors.white),
        ),
      );
    }
    return Text(
      label,
      style: CFPVTypography.buttonLabel.copyWith(color: CFPVColors.white),
    );
  }
}
