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
import '../../features/home/screens/home_screen.dart';
import '../../features/menu/presentation/pages/menu_list_page.dart';
import '../../features/menu/presentation/pages/product_detail_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/orders/presentation/pages/orders_list_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/rewards/presentation/pages/rewards_page.dart';
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

        // ── Checkout ────────────────────────
        GoRoute(
          path: RoutePaths.checkout,
          name: 'checkout',
          builder: (_, __) => const CheckoutPage(),
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
              builder: (_, __) => const HomeScreen(),
            ),
            GoRoute(
              path: RoutePaths.menu,
              name: 'menu',
              pageBuilder: (_, __) => const NoTransitionPage(
                child: MenuListPage(),
              ),
            ),
            GoRoute(
              path: RoutePaths.menuProduct,
              name: 'menuProduct',
              builder: (_, state) {
                final productId = state.pathParameters['productId']!;
                return ProductDetailPage(productId: productId);
              },
            ),
            GoRoute(
              path: RoutePaths.cart,
              name: 'cart',
              pageBuilder: (_, __) => const NoTransitionPage(
                child: CartPage(),
              ),
            ),
            GoRoute(
              path: RoutePaths.rewards,
              name: 'rewards',
              pageBuilder: (_, __) => const NoTransitionPage(
                child: RewardsPage(),
              ),
            ),
            GoRoute(
              path: RoutePaths.profile,
              name: 'profile',
              pageBuilder: (_, __) => const NoTransitionPage(
                child: ProfilePage(),
              ),
            ),
            GoRoute(
              path: RoutePaths.profileOrders,
              name: 'profileOrders',
              builder: (_, __) => const OrdersListPage(),
            ),
            GoRoute(
              path: RoutePaths.profileEdit,
              name: 'profileEdit',
              builder: (_, __) => const EditProfilePage(),
            ),
            GoRoute(
              path: RoutePaths.profileChangePassword,
              name: 'profileChangePassword',
              builder: (_, __) => const ChangePasswordPage(),
            ),
            GoRoute(
              path: RoutePaths.profileOrderDetail,
              name: 'profileOrderDetail',
              builder: (_, state) {
                final orderId = state.pathParameters['orderId']!;
                return OrderDetailPage(orderId: orderId);
              },
            ),
          ],
        ),
      ],
    );
  }
}
