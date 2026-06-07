import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/radius.dart';
import '../../theme/spacing.dart';

/// A destructive action button (red outlined) that shows a confirmation
/// [AlertDialog] before executing [onConfirm].
///
/// Use cases: "Cancel Order", "Log Out", "Delete Account" — any action
/// that needs user confirmation before proceeding.
class ConfirmationActionButton extends StatelessWidget {
  /// Icon displayed on the button.
  final IconData icon;

  /// Button label, e.g. "Cancel Order", "Log Out".
  final String label;

  /// Title of the confirmation dialog.
  final String dialogTitle;

  /// Body text of the confirmation dialog.
  final String dialogContent;

  /// Label for the confirm button (red filled).
  final String confirmLabel;

  /// Label for the cancel / dismiss button.
  final String cancelLabel;

  /// Called when the user confirms the action.
  final VoidCallback onConfirm;

  const ConfirmationActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.dialogTitle,
    required this.dialogContent,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showDialog(context),
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: CFPVColors.red,
          side: const BorderSide(color: CFPVColors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CFPVRadius.button),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: CFPVSpacing.space3,
          ),
          textStyle: CFPVTypography.buttonLabel,
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CFPVRadius.card),
        ),
        title: Text(dialogTitle),
        content: Text(dialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              cancelLabel,
              style: CFPVTypography.buttonSmall.copyWith(
                color: CFPVColors.textBlackSoft,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CFPVColors.red,
              foregroundColor: CFPVColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(CFPVRadius.button),
              ),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
