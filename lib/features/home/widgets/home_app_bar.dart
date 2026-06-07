import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/typography.dart';

/// Home screen top app bar with greeting and points badge.
/// Design: specs/design-phase.md §5.1 — HomeAppBar
class HomeAppBar extends StatelessWidget {
  final String greeting;
  final int? pointsBalance;
  final int? cartItemCount;

  const HomeAppBar({
    super.key,
    required this.greeting,
    this.pointsBalance,
    this.cartItemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CFPVColors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          // Menu / profile avatar
          const CircleAvatar(
            radius: 18,
            backgroundColor: CFPVColors.neutralCool,
            child: Icon(Icons.person_outline,
                size: 20, color: CFPVColors.textBlackSoft,),
          ),
          const SizedBox(width: 12),
          // Greeting + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  style: CFPVTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: CFPVColors.textBlack,
                  ),
                ),
                if (pointsBalance != null)
                  Text(
                    '$pointsBalance★ balance',
                    style: CFPVTypography.small.copyWith(
                      color: CFPVColors.textBlackSoft,
                    ),
                  ),
              ],
            ),
          ),
          // Points icon
          if (pointsBalance != null) ...[
            const Icon(Icons.star,
                color: CFPVColors.gold, size: 20,),
            const SizedBox(width: 12),
          ],
          // Cart icon with badge
          Stack(
            children: [
              const Icon(Icons.shopping_bag_outlined,
                  color: CFPVColors.textBlackSoft, size: 24,),
              if (cartItemCount != null && cartItemCount! > 0)
                Positioned(
                  top: -2,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: CFPVColors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                        minWidth: 16, minHeight: 16,),
                    child: Text(
                      cartItemCount! > 9 ? '9+' : '$cartItemCount',
                      style: const TextStyle(
                        color: CFPVColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
