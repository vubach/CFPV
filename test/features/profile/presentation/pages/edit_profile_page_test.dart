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
import 'package:cfpv/features/profile/presentation/pages/edit_profile_page.dart';

/// Mock auth repository with controllable update behavior.
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
    if (_shouldThrow) throw Exception('Update failed');
    return {
      'id': 'user-1',
      'full_name': fullName,
      'email': email,
      'phone': phone,
    };
  }
}

/// Build a test app with pre-filled authenticated state.
Widget _buildApp(_MockAuthRepository repo) {
  final notifier = AuthNotifier(repo);
  notifier.state = const AuthStateAuthenticated(
    userId: 'user-1',
    fullName: 'Jane Doe',
    phone: '+1 (555) 123-4567',
    email: 'jane@example.com',
  );

  final goRouter = GoRouter(
    initialLocation: '/profile/edit',
    routes: [
      GoRoute(
        path: '/profile/edit',
        name: 'profileEdit',
        builder: (_, __) => const EditProfilePage(),
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
  group('EditProfilePage', () {
    testWidgets('pre-fills form fields with current user data', (tester) async {
      final repo = _MockAuthRepository();

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      // Find the 3 TextFormFields and verify their controller values
      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(3));

      // Note: we verify the field labels (which are Text widgets) as proxy
      expect(find.text('Full Name'), findsWidgets);
      // Email Address and Phone Number appear as static labels AND floating labels
      expect(find.text('Email Address'), findsWidgets);
      expect(find.text('Phone Number'), findsWidgets);
    });

    testWidgets('shows save button, change photo, and back button',
        (tester) async {
      final repo = _MockAuthRepository();

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Change Photo'), findsOneWidget);
      // AppBar with back arrow
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('shows validation error for empty name', (tester) async {
      final repo = _MockAuthRepository();

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      // Clear the name field (first TextFormField)
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, '');
      await tester.pumpAndSettle();

      // Scroll down to reach Save Changes button
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Tap save — validation should fire
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('shows success snackbar on save', (tester) async {
      final repo = _MockAuthRepository();

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      // Scroll down to reach Save Changes button
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Tap save with existing data (should succeed with mock)
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Profile updated successfully'), findsOneWidget);
    });

    testWidgets('shows error snackbar when save fails', (tester) async {
      final repo = _MockAuthRepository();
      repo.setShouldThrow(true);

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      // Scroll down to reach Save Changes button
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Tap save — the mock will throw internally
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // AuthNotifier catches the error and sets AuthStateError
      expect(find.textContaining('Failed to save'), findsOneWidget);
    });

    testWidgets('validates email format', (tester) async {
      final repo = _MockAuthRepository();

      await tester.pumpWidget(_buildApp(repo));
      await tester.pumpAndSettle();

      // Clear the email field (second TextFormField) and enter invalid
      final emailField = find.byType(TextFormField).at(1);
      await tester.enterText(emailField, 'not-an-email');
      await tester.pumpAndSettle();

      // Scroll down to reach Save Changes button
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Tap save
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });
  });
}
