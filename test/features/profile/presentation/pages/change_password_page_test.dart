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
import 'package:cfpv/features/profile/presentation/pages/change_password_page.dart';

/// Mock auth repository with controllable changePassword behavior.
class _MockAuthRepository extends AuthRepository {
  bool _shouldThrow = false;

  _MockAuthRepository()
      : super(
          dioClient: DioClient.create(baseUrl: 'http://test.local'),
          tokenService: TokenService(
            storage: SecureStorageService(),
            dioClient: DioClient.create(baseUrl: 'http://test.local'),
          ),
        );

  void setShouldThrow(bool value) {
    _shouldThrow = value;
  }

  @override
  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    return {
      'user': {
        'id': 'user-1',
        'full_name': 'Jane Doe',
        'phone': '+1 (555) 123-4567',
      },
    };
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
    return {};
  }

  @override
  Future<Map<String, dynamic>> forgotPassword(
      {required String phone,}) async {
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

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? email,
    String? phone,
  }) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_shouldThrow) throw Exception('Current password is incorrect');
    return {'message': 'Password updated successfully'};
  }
}

/// Build a test app with authenticated state.
Widget _buildApp(_MockAuthRepository repo) {
  final notifier = AuthNotifier(repo);
  notifier.state = const AuthStateAuthenticated(
    userId: 'user-1',
    fullName: 'Jane Doe',
    phone: '+1 (555) 123-4567',
    email: 'jane@example.com',
  );

  final goRouter = GoRouter(
    initialLocation: '/profile/settings/change-password',
    routes: [
      GoRoute(
        path: '/profile/settings/change-password',
        name: 'profileChangePassword',
        builder: (_, __) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('Profile Page'))),
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
  group('ChangePasswordPage', () {
    testWidgets('shows all form fields and buttons', (tester) async {
      final repo = _MockAuthRepository();

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      expect(find.text('Current Password'), findsWidgets);
      expect(find.text('New Password'), findsWidgets);
      expect(find.text('Confirm New Password'), findsWidgets);
      expect(find.text('Update Password'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('shows instructions info box', (tester) async {
      final repo = _MockAuthRepository();

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Choose a strong password with at least 8 characters'),
        findsOneWidget,
      );
    });

    testWidgets('validates empty current password', (tester) async {
      final repo = _MockAuthRepository();

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      // Scroll down to reach Update Password button
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Password'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your current password'), findsOneWidget);
    });

    testWidgets('validates new password strength', (tester) async {
      final repo = _MockAuthRepository();

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      // Fill only the new password with a weak value
      final newPasswordField = find.byType(TextFormField).at(1);
      await tester.enterText(newPasswordField, 'short');
      await tester.pumpAndSettle();

      // Scroll to Update Password
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Password'));
      await tester.pumpAndSettle();

      expect(find.text('At least 8 characters'), findsOneWidget);
    });

    testWidgets('validates password must include number', (tester) async {
      final repo = _MockAuthRepository();

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      final newPasswordField = find.byType(TextFormField).at(1);
      await tester.enterText(newPasswordField, 'abcdefghi');
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Password'));
      await tester.pumpAndSettle();

      expect(find.text('Must include a number'), findsOneWidget);
    });

    testWidgets('validates passwords match', (tester) async {
      final repo = _MockAuthRepository();

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      // Fill new password
      final newPasswordField = find.byType(TextFormField).at(1);
      await tester.enterText(newPasswordField, 'ValidP@ss1');
      await tester.pumpAndSettle();

      // Fill confirm with different value
      final confirmField = find.byType(TextFormField).at(2);
      await tester.enterText(confirmField, 'DifferentP@ss1');
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Password'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('shows success snackbar on password change', (tester) async {
      final repo = _MockAuthRepository();

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      // Fill all fields with valid data
      await tester.enterText(find.byType(TextFormField).at(0), 'CurrentP@ss1');
      await tester.enterText(find.byType(TextFormField).at(1), 'NewP@ssword2');
      await tester.enterText(find.byType(TextFormField).at(2), 'NewP@ssword2');
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Password'));
      await tester.pumpAndSettle();

      expect(find.text('Password changed successfully'), findsOneWidget);
    });

    testWidgets('shows error snackbar on failure', (tester) async {
      final repo = _MockAuthRepository();
      repo.setShouldThrow(true);

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'CurrentP@ss1');
      await tester.enterText(find.byType(TextFormField).at(1), 'NewP@ssword2');
      await tester.enterText(find.byType(TextFormField).at(2), 'NewP@ssword2');
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Password'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed:'), findsOneWidget);
    });
  });
}
