import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cfpv/features/auth/providers/auth_provider.dart';
import 'package:cfpv/features/auth/providers/auth_state.dart';
import 'package:cfpv/features/auth/providers/otp_timer_provider.dart';
import 'package:cfpv/features/auth/repositories/auth_repository.dart';
import 'package:cfpv/core/network/dio_client.dart';
import 'package:cfpv/core/services/token_service.dart';
import 'package:cfpv/core/services/secure_storage_service.dart';

/// Mock AuthRepository that overrides all methods to avoid real API calls.
class MockAuthRepository extends AuthRepository {
  MockAuthRepository()
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
    return {
      'user': {
        'id': 'mock-user-1',
        'full_name': 'Test User',
        'phone': '1234567890',
        'email': 'test@test.com',
      },
      'tokens': {
        'accessToken': 'mock-access-token',
        'refreshToken': 'mock-refresh-token',
      },
    };
  }

  @override
  Future<Map<String, dynamic>?> register({
    required String fullName,
    required String phone,
    String? email,
    required String password,
  }) async {
    return null;
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    return {
      'user': {
        'id': 'mock-user-2',
        'full_name': 'New User',
        'phone': phone,
        'email': null,
      },
      'tokens': {
        'accessToken': 'mock-access-token',
        'refreshToken': 'mock-refresh-token',
      },
    };
  }

  @override
  Future<Map<String, dynamic>> forgotPassword({
    required String phone,
  }) async {
    return {'message': 'OTP sent'};
  }

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    return {'message': 'Password updated'};
  }

  @override
  Future<void> logout() async {}
}

/// Test-friendly AuthNotifier that extends AuthNotifier (for Riverpod
/// StateNotifierProvider override compatibility) and allows manual state
/// control via emitState(). Captures parameters passed to each method.
class TestAuthNotifier extends AuthNotifier {
  // Captured parameters from screen interactions
  String? lastLogin;
  String? lastPassword;
  String? lastFullName;
  String? lastPhone;
  String? lastEmail;
  String? lastOtp;
  String? lastNewPassword;
  Map<String, dynamic>? lastRegisterParams;
  Map<String, dynamic>? lastForgotPasswordParams;
  Map<String, dynamic>? lastResetPasswordParams;

  TestAuthNotifier() : super(MockAuthRepository());

  /// Emit a new auth state (triggers ref.listen in screens).
  void emitState(AuthState newState) {
    state = newState;
  }

  // ── Override all public methods to capture params + avoid real logic ──

  @override
  Future<void> login({
    required String login,
    required String password,
  }) async {
    lastLogin = login;
    lastPassword = password;
  }

  @override
  Future<void> register({
    required String fullName,
    required String phone,
    String? email,
    required String password,
  }) async {
    lastRegisterParams = {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'password': password,
    };
  }

  @override
  Future<void> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    lastPhone = phone;
    lastOtp = otp;
  }

  @override
  Future<void> forgotPassword({required String phone}) async {
    lastForgotPasswordParams = {'phone': phone};
  }

  @override
  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    lastResetPasswordParams = {
      'phone': phone,
      'otp': otp,
      'newPassword': newPassword,
    };
  }

  @override
  Future<void> logout() async {}
}

/// Test-friendly OtpTimerNotifier that extends OtpTimerNotifier and
/// never creates real Timers.
class TestOtpTimerNotifier extends OtpTimerNotifier {
  TestOtpTimerNotifier();

  @override
  void start() {
    state = 30; // Set state without creating a real timer
  }

  @override
  void dispose() {
    // No real timer to cancel
  }

  void emitTime(int seconds) => state = seconds;
  void resetTime() => state = 0;
}

/// Creates a test GoRouter with auth routes for testing.
GoRouter createTestRouter({
  required Widget Function(BuildContext, GoRouterState) loginBuilder,
  required Widget Function(BuildContext, GoRouterState) registerBuilder,
  required Widget Function(BuildContext, GoRouterState) forgotPasswordBuilder,
  required Widget Function(BuildContext, GoRouterState) homeBuilder,
  String initialLocation = '/login',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: loginBuilder,
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: registerBuilder,
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: forgotPasswordBuilder,
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: homeBuilder,
      ),
    ],
  );
}

/// Wraps a widget in ProviderScope with overridden auth providers and a
/// MaterialApp.router for GoRouter navigation.
///
/// Usage:
/// ```dart
/// final authNotifier = TestAuthNotifier();
/// final otpNotifier = TestOtpTimerNotifier();
///
/// await tester.pumpWidget(
///   createAuthTestApp(
///     authNotifier: authNotifier,
///     otpNotifier: otpNotifier,
///     router: createTestRouter(
///       loginBuilder: (_, __) => const LoginScreen(),
///       registerBuilder: (_, __) => const RegisterScreen(),
///       forgotPasswordBuilder: (_, __) => const ForgotPasswordScreen(),
///       homeBuilder: (_, __) => const Scaffold(body: Text('Home Page')),
///       initialLocation: '/login',
///     ),
///   ),
/// );
/// ```
Widget createAuthTestApp({
  required TestAuthNotifier authNotifier,
  required TestOtpTimerNotifier otpNotifier,
  required GoRouter router,
}) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith((ref) => authNotifier),
      otpTimerProvider.overrideWith((ref) => otpNotifier),
    ],
    child: MaterialApp.router(
      routerConfig: router,
    ),
  );
}
