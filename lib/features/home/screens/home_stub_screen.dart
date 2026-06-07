import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/home_app_bar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/auth_state.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/typography.dart';
import '../../../shared/theme/spacing.dart';
import '../../../core/router/route_paths.dart';

/// Sprint 1 minimal Home stub screen.
/// Shows greeting + hardcoded navigation links.
/// Full Home screen with hero/categories/featured ships in Sprint 6.
/// Design: specs/design-phase.md §5.1 (full — Sprint 6)
class HomeStubScreen extends ConsumerWidget {
  const HomeStubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userName = authState is AuthStateAuthenticated
        ? authState.fullName.split(' ').first
        : 'there';

    return Scaffold(
      backgroundColor: CFPVColors.neutralWarm,
      body: SafeArea(
        child: Column(
          children: [
            const HomeAppBar(
              greeting: 'Good morning!',
              pointsBalance: 0,
              cartItemCount: 0,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(CFPVSpacing.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: CFPVSpacing.space4),
                    Text(
                      'Welcome, $userName',
                      style: CFPVTypography.h1,
                    ),
                    const SizedBox(height: CFPVSpacing.space2),
                    Text(
                      'Start exploring our menu and earn rewards with every order.',
                      style: CFPVTypography.body
                          .copyWith(color: CFPVColors.textBlackSoft),
                    ),
                    const SizedBox(height: CFPVSpacing.space5),

                    // Quick nav cards
                    _NavCard(
                      icon: Icons.menu_book_outlined,
                      title: 'Browse Menu',
                      subtitle: 'Explore our full selection',
                      color: CFPVColors.greenAccent,
                      onTap: () => context.go(RoutePaths.menu),
                    ),
                    const SizedBox(height: CFPVSpacing.space3),
                    _NavCard(
                      icon: Icons.star_border,
                      title: 'Rewards',
                      subtitle: 'Check your points balance',
                      color: CFPVColors.gold,
                      onTap: () => context.go(RoutePaths.rewards),
                    ),
                    const SizedBox(height: CFPVSpacing.space3),
                    _NavCard(
                      icon: Icons.person_outline,
                      title: 'My Profile',
                      subtitle: 'Manage your account',
                      color: CFPVColors.starbucksGreen,
                      onTap: () => context.go(RoutePaths.profile),
                    ),
                    const Spacer(),
                    Text(
                      'Full Home screen — coming in Sprint 6',
                      style: CFPVTypography.small
                          .copyWith(color: CFPVColors.textBlackSoft),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: CFPVSpacing.space3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CFPVColors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(CFPVSpacing.space3),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: CFPVSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: CFPVTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: CFPVColors.textBlack,
                    )),
                    const SizedBox(height: 2),
                    Text(subtitle, style: CFPVTypography.small.copyWith(
                      color: CFPVColors.textBlackSoft,
                    )),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: CFPVColors.textBlackSoft),
            ],
          ),
        ),
      ),
    );
  }
}
