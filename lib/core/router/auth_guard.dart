import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'route_paths.dart';

/// Redirects unauthenticated users to the login screen.
class AuthGuard {
  final Ref ref;

  AuthGuard(this.ref);

  Future<String?> call(
    BuildContext context,
    GoRouterState state,
  ) async {
    final authState = ref.read(authProvider);
    final isLoggedIn = authState.isAuthenticated;
    final location = state.uri.toString();

    // Public routes — always allow
    final publicPaths = <String>{
      RoutePaths.splash,
      RoutePaths.onboarding,
      RoutePaths.login,
      RoutePaths.register,
      RoutePaths.registerVerifyOtp,
      RoutePaths.forgotPassword,
    };

    // Compare only the path component to handle query params (e.g., /login?redirect=/home)
    final currentPath = Uri.tryParse(location)?.path ?? location;
    if (publicPaths.contains(currentPath)) {
      // If already logged in and trying to access auth screens, redirect to home
      if (isLoggedIn && location != RoutePaths.splash) {
        return RoutePaths.home;
      }
      return null;
    }

    // Protected routes — redirect to login if not authenticated
    if (!isLoggedIn) {
      return '${RoutePaths.login}?redirect=$location';
    }

    return null;
  }
}
