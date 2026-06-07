import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cfpv/features/home/screens/home_stub_screen.dart';
import 'package:cfpv/features/auth/providers/auth_provider.dart';
import 'package:cfpv/features/auth/providers/auth_state.dart';
import '../../../helpers/auth_test_helper.dart';

/// Creates a test GoRouter with home, menu, rewards, and profile routes.
GoRouter _createHomeTestRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, __) => const HomeStubScreen(),
      ),
      GoRoute(
        path: '/menu',
        name: 'menu',
        builder: (_, __) => const Scaffold(body: Text('Menu Page')),
      ),
      GoRoute(
        path: '/rewards',
        name: 'rewards',
        builder: (_, __) => const Scaffold(body: Text('Rewards Page')),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (_, __) => const Scaffold(body: Text('Profile Page')),
      ),
    ],
  );
}

/// Wraps HomeStubScreen in a ProviderScope with overridden authProvider.
Widget createHomeTestApp({
  required AuthState authState,
  required GoRouter router,
}) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(
        (ref) => _TestAuthNotifier(authState),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

/// Simple AuthNotifier stub that emits the given state.
class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(AuthState initialState) : super(MockAuthRepository()) {
    state = initialState;
  }
}

extension on WidgetTester {
  Future<void> pumpHome({
    required AuthState authState,
    required GoRouter router,
  }) {
    return pumpWidget(
      createHomeTestApp(authState: authState, router: router),
    );
  }
}

void main() {
  late GoRouter router;

  setUp(() {
    router = _createHomeTestRouter();
  });

  group('HomeStubScreen', () {
    testWidgets('renders greeting and nav cards when authenticated',
        (tester) async {
      await tester.pumpHome(
        authState: const AuthStateAuthenticated(
          userId: 'user-1',
          fullName: 'Jane Doe',
          phone: '1234567890',
        ),
        router: router,
      );
      await tester.pumpAndSettle();

      // Greeting with first name
      expect(find.text('Welcome, Jane'), findsOneWidget);

      // Nav cards
      expect(find.text('Browse Menu'), findsOneWidget);
      expect(find.text('Rewards'), findsOneWidget);
      expect(find.text('My Profile'), findsOneWidget);

      // App bar greeting
      expect(find.text('Good morning!'), findsOneWidget);
    });

    testWidgets('shows generic greeting when unauthenticated',
        (tester) async {
      await tester.pumpHome(
        authState: const AuthStateUnauthenticated(),
        router: router,
      );
      await tester.pumpAndSettle();

      // Generic greeting
      expect(find.text('Welcome, there'), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpHome(
        authState: const AuthStateLoading(),
        router: router,
      );
      await tester.pumpAndSettle();

      // Generic greeting during loading
      expect(find.text('Welcome, there'), findsOneWidget);
    });

    testWidgets('Browse Menu card navigates to menu', (tester) async {
      await tester.pumpHome(
        authState: const AuthStateUnauthenticated(),
        router: router,
      );
      await tester.pumpAndSettle();

      // Tap Browse Menu card
      await tester.tap(find.text('Browse Menu'));
      await tester.pumpAndSettle();

      // Should navigate to menu
      expect(find.text('Menu Page'), findsOneWidget);
    });

    testWidgets('Rewards card navigates to rewards', (tester) async {
      await tester.pumpHome(
        authState: const AuthStateUnauthenticated(),
        router: router,
      );
      await tester.pumpAndSettle();

      // Tap Rewards card
      await tester.tap(find.text('Rewards'));
      await tester.pumpAndSettle();

      // Should navigate to rewards
      expect(find.text('Rewards Page'), findsOneWidget);
    });

    testWidgets('My Profile card navigates to profile', (tester) async {
      await tester.pumpHome(
        authState: const AuthStateUnauthenticated(),
        router: router,
      );
      await tester.pumpAndSettle();

      // Tap My Profile card
      await tester.tap(find.text('My Profile'));
      await tester.pumpAndSettle();

      // Should navigate to profile
      expect(find.text('Profile Page'), findsOneWidget);
    });

    testWidgets('shows sprint 6 placeholder text', (tester) async {
      await tester.pumpHome(
        authState: const AuthStateUnauthenticated(),
        router: router,
      );
      await tester.pumpAndSettle();

      // Placeholder text
      expect(
        find.text('Full Home screen — coming in Sprint 6'),
        findsOneWidget,
      );
    });

    testWidgets('nav cards have correct subtitle text', (tester) async {
      await tester.pumpHome(
        authState: const AuthStateUnauthenticated(),
        router: router,
      );
      await tester.pumpAndSettle();

      // Subtitle descriptions
      expect(find.text('Explore our full selection'), findsOneWidget);
      expect(find.text('Check your points balance'), findsOneWidget);
      expect(find.text('Manage your account'), findsOneWidget);
    });
  });
}
