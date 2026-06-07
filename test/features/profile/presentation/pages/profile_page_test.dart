import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cfpv/core/network/dio_client.dart';
import 'package:cfpv/core/services/secure_storage_service.dart';
import 'package:cfpv/core/services/token_service.dart';
import 'package:cfpv/features/auth/providers/auth_provider.dart';
import 'package:cfpv/features/auth/providers/auth_state.dart';
import 'package:cfpv/features/auth/repositories/auth_repository.dart';
import 'package:cfpv/features/profile/presentation/pages/profile_page.dart';

/// A mock auth repository that does nothing — the notifier state is set directly.
class _MockAuthRepository extends AuthRepository {
  _MockAuthRepository()
      : super(
          dioClient: DioClient.create(baseUrl: 'http://test.local'),
          tokenService: TokenService(
            storage: SecureStorageService(),
            dioClient: DioClient.create(baseUrl: 'http://test.local'),
          ),
        );

  @override
  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    return {'user': {'id': 'user-1', 'full_name': 'Jane Doe', 'phone': '+1 (555) 123-4567'}};
  }

  @override
  Future<void> logout() async {}

  @override
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String phone,
    String? email,
    required String password,
  }) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    return {'user': {'id': 'user-1', 'full_name': 'Jane Doe', 'phone': '+1 (555) 123-4567'}};
  }

  @override
  Future<Map<String, dynamic>> forgotPassword({required String phone}) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    return {};
  }
}

/// Build a test app with a GoRouter and a given auth state.
/// Uses a real AuthNotifier with state set directly before building.
Widget _buildApp({
  required AuthState authState,
}) {
  final notifier = AuthNotifier(_MockAuthRepository());
  notifier.state = authState;

  final goRouter = GoRouter(
    initialLocation: '/profile',
    routes: [
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (_, __) => const ProfilePage(),
      ),
      GoRoute(
        path: '/profile/orders',
        name: 'profileOrders',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('Orders Page'))),
      ),
    ],
  );

  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith((_) => notifier),
    ],
  );

  return ProviderScope(
    parent: container,
    child: MaterialApp.router(
      routerConfig: goRouter,
    ),
  );
}

void main() {
  group('ProfilePage', () {
    testWidgets('shows user name and phone from auth state', (tester) async {
      await tester.pumpWidget(_buildApp(
        authState: const AuthStateAuthenticated(
          userId: 'user-1',
          fullName: 'Jane Doe',
          phone: '+1 (555) 123-4567',
          email: 'jane@example.com',
        ),
      ),);
      await tester.pumpAndSettle();

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('jane@example.com'), findsOneWidget);
      expect(find.text('+1 (555) 123-4567'), findsOneWidget);
    });

    testWidgets('shows initials in avatar circle', (tester) async {
      await tester.pumpWidget(_buildApp(
        authState: const AuthStateAuthenticated(
          userId: 'user-1',
          fullName: 'Jane Doe',
          phone: '+1 (555) 123-4567',
        ),
      ),);
      await tester.pumpAndSettle();

      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('shows single initial for single name', (tester) async {
      await tester.pumpWidget(_buildApp(
        authState: const AuthStateAuthenticated(
          userId: 'user-1',
          fullName: 'Jane',
          phone: '+1 (555) 123-4567',
        ),
      ),);
      await tester.pumpAndSettle();

      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('shows settings menu items', (tester) async {
      await tester.pumpWidget(_buildApp(
        authState: const AuthStateAuthenticated(
          userId: 'user-1',
          fullName: 'Jane Doe',
          phone: '+1 (555) 123-4567',
        ),
      ),);
      await tester.pumpAndSettle();

      expect(find.text('Order History'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
    });

    testWidgets('tapping Order History navigates to orders page',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        authState: const AuthStateAuthenticated(
          userId: 'user-1',
          fullName: 'Jane Doe',
          phone: '+1 (555) 123-4567',
        ),
      ),);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Order History'));
      await tester.pumpAndSettle();

      expect(find.text('Orders Page'), findsOneWidget);
    });

    testWidgets('shows logout button', (tester) async {
      await tester.pumpWidget(_buildApp(
        authState: const AuthStateAuthenticated(
          userId: 'user-1',
          fullName: 'Jane Doe',
          phone: '+1 (555) 123-4567',
        ),
      ),);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Log Out'), findsWidgets);
    });

    testWidgets('logout shows confirmation dialog', (tester) async {
      await tester.pumpWidget(_buildApp(
        authState: const AuthStateAuthenticated(
          userId: 'user-1',
          fullName: 'Jane Doe',
          phone: '+1 (555) 123-4567',
        ),
      ),);
      await tester.pumpAndSettle();

      // Scroll to the logout button
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      // Tap the page's "Log Out" button
      await tester.tap(find.text('Log Out').first);
      await tester.pumpAndSettle();

      // Verify dialog content is shown
      expect(find.textContaining('Are you sure you want to log out'),
          findsOneWidget,);
      expect(find.text('Cancel'), findsOneWidget);

      // Dismiss via Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });
}
