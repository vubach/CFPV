import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/token_service.dart';
import '../../../core/services/secure_storage_service.dart';

/// Handles all auth-related API calls.
class AuthRepository {
  final DioClient _dio;
  final TokenService _tokenService;

  AuthRepository({
    required DioClient dioClient,
    required TokenService tokenService,
  })  : _dio = dioClient,
        _tokenService = tokenService;

  /// Register a new user. Returns null if OTP is hardcoded (Sprint 1 MVP).
  Future<Map<String, dynamic>?> register({
    required String fullName,
    required String phone,
    String? email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: {
        'full_name': fullName,
        'phone': phone,
        if (email != null) 'email': email,
        'password': password,
      },
    );
    return response.data as Map<String, dynamic>?;
  }

  /// Verify OTP and complete registration.
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    // Sprint 1 MVP: hardcoded OTP
    if (AppConstants.isOtpHardcoded && otp == AppConstants.hardcodedOtp) {
      return await _registerUser(phone);
    }

    final response = await _dio.post(
      ApiConstants.registerVerify,
      data: {'phone': phone, 'otp': otp},
    );
    final data = response.data as Map<String, dynamic>;
    await _saveTokens(data);
    return data;
  }

  /// Login with phone/email and password.
  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {'login': login, 'password': password},
    );
    final data = response.data as Map<String, dynamic>;
    await _saveTokens(data);
    return data;
  }

  /// Logout — clear tokens and notify server.
  Future<void> logout() async {
    try {
      final secureStorage = SecureStorageService();
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken != null) {
        await _dio.post(ApiConstants.logout, data: {
          'refreshToken': refreshToken,
        });
      }
    } catch (_) {
      // Ignore network errors on logout — just clear local state
    }
    await _tokenService.clearTokens();
  }

  /// Forgot password — request OTP.
  Future<Map<String, dynamic>> forgotPassword({required String phone}) async {
    final response = await _dio.post(
      ApiConstants.forgotPassword,
      data: {'phone': phone},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Verify forgot-password OTP and reset password.
  Future<Map<String, dynamic>> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    // Sprint 1 MVP: hardcoded OTP
    if (AppConstants.isOtpHardcoded && otp == AppConstants.hardcodedOtp) {
      return {'message': 'Password updated successfully'};
    }

    final response = await _dio.post(
      ApiConstants.forgotPasswordVerify,
      data: {
        'phone': phone,
        'otp': otp,
        'newPassword': newPassword,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  // ── Private Helpers ──────────────────────────────

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final tokens = data['tokens'] as Map<String, dynamic>;
    final accessToken = tokens['accessToken'] as String;
    final refreshToken = tokens['refreshToken'] as String;
    await _tokenService.setTokens(accessToken, refreshToken);
  }

  /// Fallback for hardcoded OTP: creates a mock user session.
  Future<Map<String, dynamic>> _registerUser(String phone) async {
    final mockUser = {
      'user': {
        'id': 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
        'full_name': 'New User',
        'phone': phone,
        'email': null,
      },
      'tokens': {
        'accessToken': 'mock-access-token',
        'refreshToken': 'mock-refresh-token',
      },
    };
    await _saveTokens(mockUser);
    return mockUser;
  }
}


