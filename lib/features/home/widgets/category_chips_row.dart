import 'package:flutter/material.dart';
import '../../menu/model/category_model.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/spacing.dart';
import '../../../shared/theme/typography.dart';

class CategoryChipsRow extends StatelessWidget {
  final List<Category> categories;
  final void Function(Category) onCategoryTap;

  const CategoryChipsRow({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: CFPVSpacing.space3),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: CFPVSpacing.space2),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryChip(
            label: category.name,
            onTap: () => onCategoryTap(category),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CFPVColors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: CFPVSpacing.space3,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: CFPVColors.inputBorder),
          ),
          child: Text(
            label,
            style: CFPVTypography.small.copyWith(
              fontWeight: FontWeight.w600,
              color: CFPVColors.textBlack,
            ),
          ),
        ),
      ),
    );
  }
}
