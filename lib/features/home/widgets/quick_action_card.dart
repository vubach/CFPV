import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/radius.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/theme/typography.dart';

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: CFPVColors.white,
        borderRadius: BorderRadius.circular(CFPVRadius.card),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CFPVRadius.card),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: iconColor ?? CFPVColors.greenAccent,
                ),
                const SizedBox(height: CFPVSpacing.space1),
                Text(
                  label,
                  style: CFPVTypography.small.copyWith(
                    fontWeight: FontWeight.w600,
                    color: CFPVColors.textBlack,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
