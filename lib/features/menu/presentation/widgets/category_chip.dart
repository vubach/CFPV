import 'package:flutter/material.dart';
import '../../model/category_model.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/radius.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/theme/typography.dart';

/// Selectable pill chip for filtering products by category.
class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: CFPVSpacing.space3,
          vertical: CFPVSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? CFPVColors.greenAccent : CFPVColors.white,
          borderRadius: BorderRadius.circular(CFPVRadius.circular),
          border: Border.all(
            color: isSelected
                ? CFPVColors.greenAccent
                : CFPVColors.inputBorder,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    offset: const Offset(0, 1),
                    blurRadius: 3,
                    color: CFPVColors.greenAccent.withOpacity(0.3),
                  ),
                ]
              : null,
        ),
        child: Text(
          category.name,
          style: CFPVTypography.smallBold.copyWith(
            color: isSelected ? CFPVColors.white : CFPVColors.textBlack,
          ),
        ),
      ),
    );
  }
}
