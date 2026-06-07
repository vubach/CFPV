import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cfpv/features/splash/screens/splash_screen.dart';
import 'package:cfpv/features/splash/providers/splash_provider.dart';
import 'package:cfpv/core/services/secure_storage_service.dart';
import 'package:cfpv/shared/widgets/feedback/loading_dots.dart';

/// Stub SplashNotifier that lets the test control state manually.
class TestSplashNotifier extends SplashNotifier {
  TestSplashNotifier() : super(SecureStorageService());

  @override
  Future<void> checkAuth() async {
    // No-op — tests call emitState directly
  }

  void emitState(SplashState newState) {
    state = newState;
  }
}

/// Creates a test GoRouter with splash, onboarding, login, and home routes.
GoRouter _createSplashTestRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (_, __) => const Scaffold(body: Text('Onboarding Page')),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const Scaffold(body: Text('Login Page')),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, __) => const Scaffold(body: Text('Home Page')),
      ),
    ],
  );
}

/// Wraps SplashScreen in a ProviderScope with overridden splashProvider.
Widget createSplashTestApp({
  required SplashNotifier notifier,
  required GoRouter router,
}) {
  return ProviderScope(
    overrides: [
      splashProvider.overrideWith((ref) => notifier),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

extension on WidgetTester {
  Future<void> pumpSplash({
    required SplashNotifier notifier,
    required GoRouter router,
  }) {
    return pumpWidget(
      createSplashTestApp(notifier: notifier, router: router),
    );
  }
}

void main() {
  late TestSplashNotifier splashNotifier;
  late GoRouter router;

  setUp(() {
    splashNotifier = TestSplashNotifier();
    router = _createSplashTestRouter();
  });

  group('SplashScreen', () {
    testWidgets('renders brand logo and loading state', (tester) async {
      await tester.pumpSplash(notifier: splashNotifier, router: router);
      // Pump multiple frames to render but avoid pumpAndSettle since
      // LoadingDots has a repeating animation that never settles
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Brand logo text (appears twice: in the circle and as the title)
      expect(find.text('CFPV'), findsAtLeast(1));

      // Subtitle
      expect(find.text('Coffee & Tea'), findsOneWidget);

      // Loading dots indicator visible while loading
      expect(find.byType(LoadingDots), findsOneWidget);

      // Version text
      expect(find.text('v1.0.0'), findsOneWidget);
    });

    testWidgets('navigates to onboarding when action is goToOnboarding',
        (tester) async {
      await tester.pumpSplash(notifier: splashNotifier, router: router);

      // Emit onboarding action
      splashNotifier.emitState(
        const SplashState(isLoading: false, action: SplashAction.goToOnboarding),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      // Should navigate to onboarding
      expect(find.text('Onboarding Page'), findsOneWidget);
    });

    testWidgets('navigates to login when action is goToLogin',
        (tester) async {
      await tester.pumpSplash(notifier: splashNotifier, router: router);

      // Emit login action
      splashNotifier.emitState(
        const SplashState(isLoading: false, action: SplashAction.goToLogin),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      // Should navigate to login
      expect(find.text('Login Page'), findsOneWidget);
    });

    testWidgets('navigates to home when action is goToHome',
        (tester) async {
      await tester.pumpSplash(notifier: splashNotifier, router: router);

      // Emit home action
      splashNotifier.emitState(
        const SplashState(isLoading: false, action: SplashAction.goToHome),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      // Should navigate to home
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('does not navigate while loading', (tester) async {
      await tester.pumpSplash(notifier: splashNotifier, router: router);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Emit a state that is still loading (no action)
      splashNotifier.emitState(
        const SplashState(isLoading: true, action: null),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should still show splash content, no navigation
      expect(find.text('CFPV'), findsAtLeast(1));
      expect(find.text('Onboarding Page'), findsNothing);
      expect(find.text('Login Page'), findsNothing);
      expect(find.text('Home Page'), findsNothing);
    });

    testWidgets('does not navigate when action is null',
        (tester) async {
      await tester.pumpSplash(notifier: splashNotifier, router: router);

      // Emit done loading but no action (shouldn't happen, but robust)
      splashNotifier.emitState(
        const SplashState(isLoading: false, action: null),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should still show splash content
      expect(find.text('CFPV'), findsAtLeast(1));
    });
  });
}
