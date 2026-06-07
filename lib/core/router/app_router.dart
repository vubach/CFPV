import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'route_paths.dart';
import 'auth_guard.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/home/screens/home_stub_screen.dart';
import '../../shared/widgets/navigation/cfpv_tab_bar.dart';

/// Provider for the GoRouter instance.
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter(ref).router;
});

class AppRouter {
  final Ref _ref;
  late final GoRouter router;

  AppRouter(this._ref) {
    final authGuard = AuthGuard(_ref);
    final navigatorKey = GlobalKey<NavigatorState>();

    router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: RoutePaths.splash,
      debugLogDiagnostics: kDebugMode,
      redirect: (context, state) => authGuard(context, state),
      routes: [
        // ── Splash ────────────────────────────
        GoRoute(
          path: RoutePaths.splash,
          name: 'splash',
          builder: (_, __) => const SplashScreen(),
        ),

        // ── Onboarding ────────────────────────
        GoRoute(
          path: RoutePaths.onboarding,
          name: 'onboarding',
          builder: (_, __) => const OnboardingScreen(),
        ),

        // ── Auth Routes ───────────────────────
        GoRoute(
          path: RoutePaths.login,
          name: 'login',
          builder: (_, state) => LoginScreen(
            redirectPath: state.uri.queryParameters['redirect'],
          ),
        ),
        GoRoute(
          path: RoutePaths.register,
          name: 'register',
          builder: (_, __) => const RegisterScreen(),
        ),
        GoRoute(
          path: RoutePaths.forgotPassword,
          name: 'forgotPassword',
          builder: (_, __) => const ForgotPasswordScreen(),
        ),

        // ── Authenticated Shell (with Tab Bar) ──
        ShellRoute(
          builder: (_, __, child) => CFPVTabShell(child: child),
          routes: [
            GoRoute(
              path: RoutePaths.home,
              name: 'home',
              builder: (_, __) => const HomeStubScreen(),
            ),
            GoRoute(
              path: RoutePaths.menu,
              name: 'menu',
              pageBuilder: (_, __) => NoTransitionPage(
                child: const Scaffold(
                  body: Center(child: Text('Menu — Coming in Sprint 2')),
                ),
              ),
            ),
            GoRoute(
              path: RoutePaths.cart,
              name: 'cart',
              pageBuilder: (_, __) => NoTransitionPage(
                child: const Scaffold(
                  body: Center(child: Text('Cart — Coming in Sprint 3')),
                ),
              ),
            ),
            GoRoute(
              path: RoutePaths.rewards,
              name: 'rewards',
              pageBuilder: (_, __) => NoTransitionPage(
                child: const Scaffold(
                  body: Center(child: Text('Rewards — Coming in Sprint 5')),
                ),
              ),
            ),
            GoRoute(
              path: RoutePaths.profile,
              name: 'profile',
              pageBuilder: (_, __) => NoTransitionPage(
                child: const Scaffold(
                  body: Center(child: Text('Profile — Coming in Sprint 6')),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
