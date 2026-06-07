import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'secure_storage_service.dart';
import '../network/dio_client.dart';

/// Manages JWT access and refresh token lifecycle.
class TokenService {
  final SecureStorageService _storage;
  final DioClient _dioClient;

  TokenService({
    required SecureStorageService storage,
    required DioClient dioClient,
  })  : _storage = storage,
        _dioClient = dioClient;

  Future<String?> getAccessToken() => _storage.getAccessToken();

  Future<void> setTokens(String accessToken, String refreshToken) async {
    await _storage.setAccessToken(accessToken);
    await _storage.setRefreshToken(refreshToken);
  }

  Future<String?> refreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final response = await _dioClient.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      final newAccess = data['accessToken'] as String;
      final newRefresh = data['refreshToken'] as String;

      await setTokens(newAccess, newRefresh);
      return newAccess;
    } on DioException {
      await clearTokens();
      return null;
    }
  }

  Future<bool> hasValidToken() async {
    final token = await _storage.getAccessToken();
    return token != null;
  }

  Future<void> clearTokens() async {
    await _storage.clearAccessToken();
    await _storage.clearRefreshToken();
  }
}
