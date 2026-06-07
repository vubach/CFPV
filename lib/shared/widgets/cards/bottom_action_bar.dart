import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';

/// A white bottom bar container with a top shadow and safe-area-aware padding.
///
/// Used as the wrapper for cart and checkout bottom action bars.
/// Takes a [child] (typically a [Column] with totals and a CTA button).
class BottomActionBar extends StatelessWidget {
  final Widget child;

  const BottomActionBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        CFPVSpacing.space4,
        CFPVSpacing.space3,
        CFPVSpacing.space4,
        MediaQuery.of(context).padding.bottom + CFPVSpacing.space3,
      ),
      decoration: BoxDecoration(
        color: CFPVColors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: child,
    );
  }
}
