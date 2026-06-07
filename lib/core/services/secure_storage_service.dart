import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

/// Wraps FlutterSecureStorage with typed accessors.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  // ── Access Token ──────────────────────────────────
  Future<String?> getAccessToken() =>
      _storage.read(key: StorageKeys.accessToken);

  Future<void> setAccessToken(String token) =>
      _storage.write(key: StorageKeys.accessToken, value: token);

  Future<void> clearAccessToken() =>
      _storage.delete(key: StorageKeys.accessToken);

  // ── Refresh Token ─────────────────────────────────
  Future<String?> getRefreshToken() =>
      _storage.read(key: StorageKeys.refreshToken);

  Future<void> setRefreshToken(String token) =>
      _storage.write(key: StorageKeys.refreshToken, value: token);

  Future<void> clearRefreshToken() =>
      _storage.delete(key: StorageKeys.refreshToken);

  // ── Onboarding ────────────────────────────────────
  Future<bool> hasSeenOnboarding() async {
    final value = await _storage.read(key: StorageKeys.hasSeenOnboarding);
    return value == 'true';
  }

  Future<void> markOnboardingSeen() =>
      _storage.write(key: StorageKeys.hasSeenOnboarding, value: 'true');

  // ── FCM Token ─────────────────────────────────────
  Future<String?> getFcmToken() =>
      _storage.read(key: StorageKeys.fcmToken);

  Future<void> setFcmToken(String token) =>
      _storage.write(key: StorageKeys.fcmToken, value: token);

  // ── Cache ─────────────────────────────────────────
  Future<String?> getCachedUserId() =>
      _storage.read(key: StorageKeys.cachedUserId);

  Future<void> setCachedUserId(String id) =>
      _storage.write(key: StorageKeys.cachedUserId, value: id);

  Future<String?> getCachedUserData() =>
      _storage.read(key: StorageKeys.cachedUserData);

  Future<void> setCachedUserData(String json) =>
      _storage.write(key: StorageKeys.cachedUserData, value: json);

  // ── Clear All ─────────────────────────────────────
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
