import 'package:flutter/material.dart';
import 'card_container.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';

/// A card displaying free-form notes text with a "Notes" header.
class NotesCard extends StatelessWidget {
  final String title;
  final String notes;

  const NotesCard({
    super.key,
    this.title = 'Order Notes',
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: CFPVTypography.smallBold.copyWith(
              color: CFPVColors.textBlackSoft,
            ),
          ),
          const SizedBox(height: CFPVSpacing.space2),
          Text(
            notes,
            style: CFPVTypography.body.copyWith(
              color: CFPVColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }
}
