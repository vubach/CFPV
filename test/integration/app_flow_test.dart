import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import 'package:cfpv/features/splash/screens/splash_screen.dart';
import 'package:cfpv/features/splash/providers/splash_provider.dart';
import 'package:cfpv/features/onboarding/screens/onboarding_screen.dart';
import 'package:cfpv/features/auth/screens/login_screen.dart';
import 'package:cfpv/features/auth/screens/register_screen.dart';
import 'package:cfpv/features/auth/screens/forgot_password_screen.dart';
import 'package:cfpv/features/auth/providers/auth_provider.dart';
import 'package:cfpv/features/auth/providers/auth_state.dart';
import 'package:cfpv/features/auth/providers/otp_timer_provider.dart';
import 'package:cfpv/features/home/screens/home_stub_screen.dart';
import 'package:cfpv/shared/widgets/navigation/cfpv_tab_bar.dart';
import 'package:cfpv/core/router/route_paths.dart';
import 'package:cfpv/core/services/secure_storage_service.dart';
import '../helpers/auth_test_helper.dart';

// ── Test Splash Notifier ─────────────────────────────────────
class _IntegrationTestSplashNotifier extends SplashNotifier {
  _IntegrationTestSplashNotifier() : super(SecureStorageService());

  @override
  Future<void> checkAuth() async {
    // No-op — tests control state via emitState
  }

  void emitState(SplashState newState) {
    state = newState;
  }
}

// ── Auth Guard ───────────────────────────────────────────────
class _TestAuthGuard {
  final WidgetRef ref;

  _TestAuthGuard(this.ref);

  Future<String?> call(BuildContext context, GoRouterState state) async {
    final authState = ref.read(authProvider);
    final isLoggedIn = authState.isAuthenticated;
    final currentPath = state.uri.toString().split('?').first;

    final publicPaths = <String>{
      RoutePaths.splash,
      RoutePaths.onboarding,
      RoutePaths.login,
      RoutePaths.register,
      RoutePaths.forgotPassword,
    };

    if (publicPaths.contains(currentPath)) {
      return null;
    }

    if (!isLoggedIn) {
      return '${RoutePaths.login}?redirect=$currentPath';
    }

    return null;
  }
}

// ── Test App Router ──────────────────────────────────────────
GoRouter _createIntegrationTestRouter(WidgetRef ref) {
  final authGuard = _TestAuthGuard(ref);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    redirect: (context, state) => authGuard(context, state),
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
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
            pageBuilder: (_, __) => const NoTransitionPage(
              child: Scaffold(
                body: Center(child: Text('Menu — Coming in Sprint 2')),
              ),
            ),
          ),
          GoRoute(
            path: RoutePaths.cart,
            name: 'cart',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: Scaffold(
                body: Center(child: Text('Cart — Coming in Sprint 3')),
              ),
            ),
          ),
          GoRoute(
            path: RoutePaths.rewards,
            name: 'rewards',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: Scaffold(
                body: Center(child: Text('Rewards — Coming in Sprint 5')),
              ),
            ),
          ),
          GoRoute(
            path: RoutePaths.profile,
            name: 'profile',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: Scaffold(
                body: Center(child: Text('Profile — Coming in Sprint 6')),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

void main() {
  // Mock FlutterSecureStorage channel so SecureStorageService works
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/flutter_secure_storage'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'read':
          case 'containsKey':
            return null;
          case 'write':
            return true;
          case 'delete':
          case 'deleteAll':
            return true;
          case 'readAll':
            return <String, dynamic>{};
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/flutter_secure_storage'),
      null,
    );
  });

  /// Pumps the full integration test app with all provider overrides.
  Future<void> pumpApp({
    required WidgetTester tester,
    required _IntegrationTestSplashNotifier splashNotifier,
    required TestAuthNotifier authNotifier,
    required TestOtpTimerNotifier otpNotifier,
  }) async {
    GoRouter? router;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          splashProvider.overrideWith((ref) => splashNotifier),
          authProvider.overrideWith((ref) => authNotifier),
          otpTimerProvider.overrideWith((ref) => otpNotifier),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            router ??= _createIntegrationTestRouter(ref);
            return MaterialApp.router(routerConfig: router!);
          },
        ),
      ),
    );
  }

  group('Full app flow', () {
    testWidgets('splash → onboarding (new user flow)', (tester) async {
      final splashNotifier = _IntegrationTestSplashNotifier();
      final authNotifier = TestAuthNotifier();
      final otpNotifier = TestOtpTimerNotifier();

      await pumpApp(
        tester: tester,
        splashNotifier: splashNotifier,
        authNotifier: authNotifier,
        otpNotifier: otpNotifier,
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SplashScreen), findsOneWidget);

      splashNotifier.emitState(
        const SplashState(isLoading: false, action: SplashAction.goToOnboarding),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Browse & Order'), findsOneWidget);
    });

    testWidgets('splash → login (returning user without session)',
        (tester) async {
      final splashNotifier = _IntegrationTestSplashNotifier();
      final authNotifier = TestAuthNotifier();
      final otpNotifier = TestOtpTimerNotifier();

      await pumpApp(
        tester: tester,
        splashNotifier: splashNotifier,
        authNotifier: authNotifier,
        otpNotifier: otpNotifier,
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SplashScreen), findsOneWidget);

      splashNotifier.emitState(
        const SplashState(isLoading: false, action: SplashAction.goToLogin),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('splash → home (authenticated user)', (tester) async {
      final splashNotifier = _IntegrationTestSplashNotifier();
      final authNotifier = TestAuthNotifier();
      final otpNotifier = TestOtpTimerNotifier();

      authNotifier.emitState(
        const AuthStateAuthenticated(
          userId: 'user-1',
          fullName: 'Test User',
          phone: '1234567890',
        ),
      );

      await pumpApp(
        tester: tester,
        splashNotifier: splashNotifier,
        authNotifier: authNotifier,
        otpNotifier: otpNotifier,
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      splashNotifier.emitState(
        const SplashState(isLoading: false, action: SplashAction.goToHome),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Good morning!'), findsOneWidget);
      expect(find.text('Welcome, Test'), findsOneWidget);
    });

    testWidgets('auth guard redirects unauthenticated to login',
        (tester) async {
      final splashNotifier = _IntegrationTestSplashNotifier();
      final authNotifier = TestAuthNotifier();
      final otpNotifier = TestOtpTimerNotifier();

      await pumpApp(
        tester: tester,
        splashNotifier: splashNotifier,
        authNotifier: authNotifier,
        otpNotifier: otpNotifier,
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      splashNotifier.emitState(
        const SplashState(isLoading: false, action: SplashAction.goToHome),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('login → home (successful authentication)', (tester) async {
      final splashNotifier = _IntegrationTestSplashNotifier();
      final authNotifier = TestAuthNotifier();
      final otpNotifier = TestOtpTimerNotifier();

      await pumpApp(
        tester: tester,
        splashNotifier: splashNotifier,
        authNotifier: authNotifier,
        otpNotifier: otpNotifier,
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      splashNotifier.emitState(
        const SplashState(isLoading: false, action: SplashAction.goToLogin),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@test.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      authNotifier.emitState(
        const AuthStateAuthenticated(
          userId: 'user-1',
          fullName: 'Test User',
          phone: '1234567890',
        ),
      );

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Good morning!'), findsOneWidget);
      expect(find.text('Welcome, Test'), findsOneWidget);
    });

    testWidgets('full flow: splash → onboarding → login → home',
        (tester) async {
      final splashNotifier = _IntegrationTestSplashNotifier();
      final authNotifier = TestAuthNotifier();
      final otpNotifier = TestOtpTimerNotifier();

      await pumpApp(
        tester: tester,
        splashNotifier: splashNotifier,
        authNotifier: authNotifier,
        otpNotifier: otpNotifier,
      );

      // ── Step 1: Splash → Onboarding ──
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SplashScreen), findsOneWidget);

      splashNotifier.emitState(
        const SplashState(isLoading: false, action: SplashAction.goToOnboarding),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsOneWidget);

      // ── Step 2: Onboarding → Login (via Skip) ──
      await tester.runAsync(() async {
        await tester.tap(find.text('Skip'));
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Welcome Back'), findsOneWidget);

      // ── Step 3: Login → Home ──
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@test.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      authNotifier.emitState(
        const AuthStateAuthenticated(
          userId: 'user-1',
          fullName: 'Test User',
          phone: '1234567890',
        ),
      );

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Good morning!'), findsOneWidget);
      expect(find.text('Welcome, Test'), findsOneWidget);
    });
  });
}
