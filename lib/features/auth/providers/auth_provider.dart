import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state.dart';
import '../repositories/auth_repository.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/token_service.dart';
import '../../../core/services/secure_storage_service.dart';

/// Auth provider for login/register/logout flows.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthStateInitial());

  Future<void> checkSession() async {
    final storage = SecureStorageService();
    final token = await storage.getAccessToken();
    if (token != null) {
      final userId = await storage.getCachedUserId();
      final userData = await storage.getCachedUserData();
      if (userId != null) {
        state = AuthStateAuthenticated(
          userId: userId,
          fullName: 'User',
          phone: '',
        );
        return;
      }
    }
    state = const AuthStateUnauthenticated();
  }

  Future<void> login({
    required String login,
    required String password,
  }) async {
    state = const AuthStateLoading();
    try {
      final data = await _repository.login(login: login, password: password);
      final user = data['user'] as Map<String, dynamic>;
      final storage = SecureStorageService();
      await storage.setCachedUserId(user['id'] as String);

      state = AuthStateAuthenticated(
        userId: user['id'] as String,
        fullName: user['full_name'] as String,
        phone: user['phone'] as String,
        email: user['email'] as String?,
        avatarUrl: user['avatarUrl'] as String?,
      );
    } catch (e) {
      state = AuthStateError(message: e.toString());
    }
  }

  Future<void> register({
    required String fullName,
    required String phone,
    String? email,
    required String password,
  }) async {
    state = const AuthStateLoading();
    try {
      await _repository.register(
        fullName: fullName,
        phone: phone,
        email: email,
        password: password,
      );
      // OTP sent — return to loading state for OTP verification
      state = const AuthStateInitial();
    } catch (e) {
      state = AuthStateError(message: e.toString());
    }
  }

  Future<void> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    state = const AuthStateLoading();
    try {
      final data = await _repository.verifyOtp(phone: phone, otp: otp);
      final user = data['user'] as Map<String, dynamic>;
      final storage = SecureStorageService();
      await storage.setCachedUserId(user['id'] as String);

      state = AuthStateAuthenticated(
        userId: user['id'] as String,
        fullName: user['full_name'] as String,
        phone: user['phone'] as String,
        email: user['email'] as String?,
      );
    } catch (e) {
      state = AuthStateError(message: e.toString());
    }
  }

  Future<void> forgotPassword({required String phone}) async {
    state = const AuthStateLoading();
    try {
      await _repository.forgotPassword(phone: phone);
      state = const AuthStateInitial();
    } catch (e) {
      state = AuthStateError(message: e.toString());
    }
  }

  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    state = const AuthStateLoading();
    try {
      await _repository.resetPassword(
        phone: phone,
        otp: otp,
        newPassword: newPassword,
      );
      state = const AuthStateInitial();
    } catch (e) {
      state = AuthStateError(message: e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {
      // Proceed with local logout even on network error
    }
    state = const AuthStateUnauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final dio = DioClient.instance;
  final storage = SecureStorageService();
  final tokenService = TokenService(storage: storage, dioClient: dio);
  final repository = AuthRepository(dioClient: dio, tokenService: tokenService);
  return AuthNotifier(repository);
});
