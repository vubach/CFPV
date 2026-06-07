import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../theme/typography.dart';

/// Error state with icon, title, message, and a "Try Again" retry button.
/// Used across multiple pages (cart, orders, rewards) as the error state.
class StateError extends StatelessWidget {
  /// The primary error title, e.g. "Could not load orders".
  final String title;

  /// The detailed error message from the exception.
  final String message;

  /// Callback invoked when the user taps "Try Again".
  final VoidCallback onRetry;

  const StateError({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
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
              Icons.error_outline,
              size: 48,
              color: CFPVColors.red.withOpacity(0.7),
            ),
            const SizedBox(height: CFPVSpacing.space3),
            Text(
              title,
              style: CFPVTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                color: CFPVColors.textBlack,
              ),
            ),
            const SizedBox(height: CFPVSpacing.space2),
            Text(
              message,
              style: CFPVTypography.small.copyWith(
                color: CFPVColors.textBlackSoft,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: CFPVSpacing.space4),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: CFPVColors.greenAccent,
                foregroundColor: CFPVColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CFPVRadius.button),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: CFPVSpacing.space4,
                  vertical: CFPVSpacing.space2,
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
