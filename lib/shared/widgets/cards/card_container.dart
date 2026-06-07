import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/radius.dart';
import '../../theme/spacing.dart';

/// Standard white card container with rounded corners and shadow.
/// Used across the app as the base wrapper for card-style content.
///
/// Applies:
/// - White background
/// - [CFPVRadius.card] border radius
/// - Standard box shadow
/// - [CFPVSpacing.space4] padding by default
class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const CardContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(CFPVSpacing.space4),
      decoration: BoxDecoration(
        color: CFPVColors.white,
        borderRadius: BorderRadius.circular(CFPVRadius.card),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 0),
            blurRadius: 0.5,
            color: Colors.black.withOpacity(0.14),
          ),
          BoxShadow(
            offset: const Offset(0, 1),
            blurRadius: 1,
            color: Colors.black.withOpacity(0.24),
          ),
        ],
      ),
      child: child,
    );
  }
}
