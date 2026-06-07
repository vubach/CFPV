import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/splash_provider.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/typography.dart';
import '../../../core/router/route_paths.dart';
import '../../../shared/widgets/feedback/loading_dots.dart';
import '../../../shared/widgets/app_logo.dart';

/// Brand loading screen. Auto-navigates based on auth state.
/// Design: specs/design-phase.md §3.1
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(splashProvider.notifier).checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SplashState>(splashProvider, (_, state) {
      if (!state.isLoading && state.action != null) {
        _navigate(state.action!);
      }
    });

    return Scaffold(
      backgroundColor: CFPVColors.neutralWarm,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo(size: 120, fontSize: 28),
              const SizedBox(height: 4),
              Text(
                'Coffee & Tea',
                style: CFPVTypography.body.copyWith(
                  color: CFPVColors.textBlackSoft,
                ),
              ),
              const Spacer(),
              // Loading indicator
              const LoadingDots(),
              const SizedBox(height: 24),
              Text(
                'v1.0.0',
                style: CFPVTypography.micro.copyWith(
                  color: CFPVColors.textBlackSoft,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(SplashAction action) {
    switch (action) {
      case SplashAction.goToOnboarding:
        context.go(RoutePaths.onboarding);
      case SplashAction.goToLogin:
        context.go(RoutePaths.login);
      case SplashAction.goToHome:
        context.go(RoutePaths.home);
    }
  }
}
