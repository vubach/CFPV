import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CFPVSpacing.space3),
      child: Row(
        children: [
          Text(title, style: CFPVTypography.h2),
          if (trailing != null) ...[
            const Spacer(),
            Text(
              trailing!,
              style: CFPVTypography.small.copyWith(
                color: CFPVColors.greenAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
