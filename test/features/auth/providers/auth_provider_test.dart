import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cfpv/features/auth/providers/auth_provider.dart';
import 'package:cfpv/features/auth/providers/auth_state.dart';
import 'package:cfpv/features/auth/repositories/auth_repository.dart';
import 'package:cfpv/core/network/dio_client.dart';
import 'package:cfpv/core/services/token_service.dart';
import 'package:cfpv/core/services/secure_storage_service.dart';

/// AuthRepository that returns successful responses.
class _SuccessAuthRepository extends AuthRepository {
  _SuccessAuthRepository()
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

/// AuthRepository that throws on all methods.
class _ThrowingAuthRepository extends AuthRepository {
  _ThrowingAuthRepository()
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
    throw Exception('Login failed');
  }

  @override
  Future<Map<String, dynamic>?> register({
    required String fullName,
    required String phone,
    String? email,
    required String password,
  }) async {
    throw Exception('Registration failed');
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    throw Exception('OTP verification failed');
  }

  @override
  Future<Map<String, dynamic>> forgotPassword({
    required String phone,
  }) async {
    throw Exception('Forgot password failed');
  }

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    throw Exception('Reset password failed');
  }

  @override
  Future<void> logout() async {
    throw Exception('Logout failed');
  }
}

/// Configurable storage values for checkSession() tests.
Map<String, String?> _mockStorageValues = {};

void main() {
  setUp(() {
    _mockStorageValues = {};

    /// Mock handler for flutter_secure_storage v9+ (it_nomads channel).
    Future<dynamic> mockHandler(MethodCall methodCall) async {
      // arguments is a Map in v9+ (e.g., {'key': 'cfpv_access_token'})
      final args = methodCall.arguments;
      final map = (args is Map) ? Map<String, dynamic>.from(args) : null;
      switch (methodCall.method) {
        case 'read':
          return map?['key'] != null ? _mockStorageValues[map!['key']] : null;
        case 'write':
          return true;
        case 'containsKey':
          return map?['key'] != null &&
              _mockStorageValues.containsKey(map!['key']);
        case 'delete':
        case 'deleteAll':
          return true;
        case 'readAll':
          return Map<String, String>.from(_mockStorageValues);
        default:
          return null;
      }
    }

    // Mock both the old and new channel names for compatibility
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      mockHandler,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/flutter_secure_storage'),
      mockHandler,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/flutter_secure_storage'),
      null,
    );
  });

  group('AuthNotifier', () {
    testWidgets('starts with AuthStateInitial', (_) async {
      final notifier = AuthNotifier(_SuccessAuthRepository());
      expect(notifier.state, isA<AuthStateInitial>());
    });

    group('login()', () {
      testWidgets('emits loading then authenticated on success',
          (tester) async {
        final notifier = AuthNotifier(_SuccessAuthRepository());

        // Start login and capture the future
        final future = notifier.login(
          login: 'test@test.com',
          password: 'pass123',
        );
        // Loading is set synchronously before the first await
        expect(notifier.state, isA<AuthStateLoading>());

        // Wait for completion inside runAsync (handles method channel calls)
        await tester.runAsync(() => future);

        expect(notifier.state, isA<AuthStateAuthenticated>());
        final auth = notifier.state as AuthStateAuthenticated;
        expect(auth.userId, 'mock-user-1');
        expect(auth.fullName, 'Test User');
      });

      testWidgets('emits error on failure', (tester) async {
        final notifier = AuthNotifier(_ThrowingAuthRepository());

        final future = notifier.login(
          login: 'test@test.com',
          password: 'pass123',
        );
        expect(notifier.state, isA<AuthStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<AuthStateError>());
        expect(
          (notifier.state as AuthStateError).message,
          contains('Login failed'),
        );
      });
    });

    group('register()', () {
      testWidgets('emits initial on success (OTP sent)', (tester) async {
        final notifier = AuthNotifier(_SuccessAuthRepository());

        final future = notifier.register(
          fullName: 'New User',
          phone: '0987654321',
          email: 'new@test.com',
          password: 'pass123',
        );
        expect(notifier.state, isA<AuthStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<AuthStateInitial>());
      });

      testWidgets('register without email succeeds', (tester) async {
        final notifier = AuthNotifier(_SuccessAuthRepository());

        final future = notifier.register(
          fullName: 'New User',
          phone: '0987654321',
          password: 'pass123',
        );
        expect(notifier.state, isA<AuthStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<AuthStateInitial>());
      });

      testWidgets('emits error on failure', (tester) async {
        final notifier = AuthNotifier(_ThrowingAuthRepository());

        final future = notifier.register(
          fullName: 'New User',
          phone: '0987654321',
          password: 'pass123',
        );
        expect(notifier.state, isA<AuthStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<AuthStateError>());
        expect(
          (notifier.state as AuthStateError).message,
          contains('Registration failed'),
        );
      });
    });

    group('verifyOtp()', () {
      testWidgets('emits authenticated on success', (tester) async {
        final notifier = AuthNotifier(_SuccessAuthRepository());

        final future = notifier.verifyOtp(
          phone: '0987654321',
          otp: '123456',
        );
        expect(notifier.state, isA<AuthStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<AuthStateAuthenticated>());
        final auth = notifier.state as AuthStateAuthenticated;
        expect(auth.userId, 'mock-user-2');
        expect(auth.fullName, 'New User');
      });

      testWidgets('emits error on failure', (tester) async {
        final notifier = AuthNotifier(_ThrowingAuthRepository());

        final future = notifier.verifyOtp(
          phone: '0987654321',
          otp: '000000',
        );
        expect(notifier.state, isA<AuthStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<AuthStateError>());
        expect(
          (notifier.state as AuthStateError).message,
          contains('OTP verification failed'),
        );
      });
    });

    group('forgotPassword()', () {
      testWidgets('emits initial on success', (tester) async {
        final notifier = AuthNotifier(_SuccessAuthRepository());

        final future = notifier.forgotPassword(phone: '0987654321');
        expect(notifier.state, isA<AuthStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<AuthStateInitial>());
      });

      testWidgets('emits error on failure', (tester) async {
        final notifier = AuthNotifier(_ThrowingAuthRepository());

        final future = notifier.forgotPassword(phone: '0987654321');
        expect(notifier.state, isA<AuthStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<AuthStateError>());
        expect(
          (notifier.state as AuthStateError).message,
          contains('Forgot password failed'),
        );
      });
    });

    group('resetPassword()', () {
      testWidgets('emits initial on success', (tester) async {
        final notifier = AuthNotifier(_SuccessAuthRepository());

        final future = notifier.resetPassword(
          phone: '0987654321',
          otp: '123456',
          newPassword: 'newpass123',
        );
        expect(notifier.state, isA<AuthStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<AuthStateInitial>());
      });

      testWidgets('emits error on failure', (tester) async {
        final notifier = AuthNotifier(_ThrowingAuthRepository());

        final future = notifier.resetPassword(
          phone: '0987654321',
          otp: '000000',
          newPassword: 'newpass123',
        );
        expect(notifier.state, isA<AuthStateLoading>());

        await tester.runAsync(() => future);

        expect(notifier.state, isA<AuthStateError>());
        expect(
          (notifier.state as AuthStateError).message,
          contains('Reset password failed'),
        );
      });
    });

    group('logout()', () {
      testWidgets('emits unauthenticated', (tester) async {
        final notifier = AuthNotifier(_SuccessAuthRepository());

        final future = notifier.logout();
        // logout() doesn't set loading state
        await tester.runAsync(() => future);

        expect(notifier.state, isA<AuthStateUnauthenticated>());
      });

      testWidgets('still emits unauthenticated when repo throws',
          (tester) async {
        final notifier = AuthNotifier(_ThrowingAuthRepository());

        final future = notifier.logout();
        await tester.runAsync(() => future);

        expect(notifier.state, isA<AuthStateUnauthenticated>());
      });
    });

    group('checkSession()', () {
      testWidgets('emits authenticated when tokens exist',
          (tester) async {
        _mockStorageValues = {
          'cfpv_access_token': 'mock-access-token',
          'cfpv_cached_user_id': 'user-1',
          'cfpv_cached_user_data': '{"name": "Test"}',
        };

        final notifier = AuthNotifier(_SuccessAuthRepository());

        final future = notifier.checkSession();
        await tester.runAsync(() => future);

        expect(notifier.state, isA<AuthStateAuthenticated>());
        expect(
          (notifier.state as AuthStateAuthenticated).userId,
          'user-1',
        );
      });

      testWidgets('emits unauthenticated when no tokens',
          (tester) async {
        _mockStorageValues = {};

        final notifier = AuthNotifier(_SuccessAuthRepository());

        final future = notifier.checkSession();
        await tester.runAsync(() => future);

        expect(notifier.state, isA<AuthStateUnauthenticated>());
      });

      testWidgets('emits unauthenticated when no user ID',
          (tester) async {
        _mockStorageValues = {
          'cfpv_access_token': 'mock-access-token',
        };

        final notifier = AuthNotifier(_SuccessAuthRepository());

        final future = notifier.checkSession();
        await tester.runAsync(() => future);

        expect(notifier.state, isA<AuthStateUnauthenticated>());
      });
    });
  });
}
