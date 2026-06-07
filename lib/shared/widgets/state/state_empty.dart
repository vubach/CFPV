import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../theme/typography.dart';

/// An optional action button shown below the empty-state description.
class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: CFPVColors.greenAccent,
        foregroundColor: CFPVColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CFPVRadius.button),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: CFPVSpacing.space5,
          vertical: CFPVSpacing.space2,
        ),
      ),
      child: Text(label),
    );
  }
}

/// Empty state with icon, title, description, and an optional action button.
/// Used across pages (cart, orders, rewards) as the empty-state display.
class StateEmpty extends StatelessWidget {
  /// The icon to display (e.g. Icons.receipt_long_outlined).
  final IconData icon;

  /// The primary title text, e.g. "No orders yet".
  final String title;

  /// The descriptive subtitle, e.g. "Place your first order and it will appear here."
  final String description;

  /// Optional action button — shown when both [actionLabel] and [actionOnPressed] are set.
  final String? actionLabel;
  final VoidCallback? actionOnPressed;

  const StateEmpty({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.actionOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CFPVSpacing.space4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: CFPVColors.textBlackSoft.withOpacity(0.5),
            ),
            const SizedBox(height: CFPVSpacing.space4),
            Text(
              title,
              style: CFPVTypography.h2.copyWith(
                color: CFPVColors.textBlackSoft,
              ),
            ),
            const SizedBox(height: CFPVSpacing.space2),
            Text(
              description,
              style: CFPVTypography.body.copyWith(
                color: CFPVColors.textBlackSoft.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && actionOnPressed != null) ...[
              const SizedBox(height: CFPVSpacing.space5),
              _ActionButton(label: actionLabel!, onPressed: actionOnPressed!),
            ],
          ],
        ),
      ),
    );
  }
}
