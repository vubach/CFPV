import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cfpv/features/splash/providers/splash_provider.dart';
import 'package:cfpv/core/services/secure_storage_service.dart';
import 'package:cfpv/core/constants/storage_keys.dart';

/// Configurable storage values for FlutterSecureStorage mock.
Map<String, String?> _mockStorageValues = {};

/// Shared mock handler for FlutterSecureStorage channel.
Future<dynamic> _mockStorageHandler(MethodCall methodCall) async {
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

/// Creates a SplashNotifier that reads from the mocked channel.
SplashNotifier _createNotifier() {
  return SplashNotifier(SecureStorageService());
}

void main() {
  setUp(() {
    _mockStorageValues = {};

    // Mock both channel names for flutter_secure_storage compatibility
    for (final channel in [
      'plugins.it_nomads.com/flutter_secure_storage',
      'plugins.flutter.io/flutter_secure_storage',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        MethodChannel(channel),
        _mockStorageHandler,
      );
    }
  });

  tearDown(() {
    for (final channel in [
      'plugins.it_nomads.com/flutter_secure_storage',
      'plugins.flutter.io/flutter_secure_storage',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        MethodChannel(channel),
        null,
      );
    }
  });

  group('SplashNotifier', () {
    testWidgets('starts with isLoading true and no action', (_) async {
      final notifier = _createNotifier();
      expect(notifier.state.isLoading, true);
      expect(notifier.state.action, isNull);
    });

    testWidgets(
        'checkAuth() with no onboarding seen → goToOnboarding',
        (tester) async {
      final notifier = _createNotifier();
      _mockStorageValues = {};

      await tester.runAsync(() => notifier.checkAuth());

      expect(notifier.state.isLoading, false);
      expect(notifier.state.action, SplashAction.goToOnboarding);
    });

    testWidgets(
        'checkAuth() with onboarding seen but no token → goToLogin',
        (tester) async {
      final notifier = _createNotifier();
      _mockStorageValues = {
        StorageKeys.hasSeenOnboarding: 'true',
      };

      await tester.runAsync(() => notifier.checkAuth());

      expect(notifier.state.isLoading, false);
      expect(notifier.state.action, SplashAction.goToLogin);
    });

    testWidgets(
        'checkAuth() with onboarding seen and token → goToHome',
        (tester) async {
      final notifier = _createNotifier();
      _mockStorageValues = {
        StorageKeys.hasSeenOnboarding: 'true',
        StorageKeys.accessToken: 'mock-access-token',
      };

      await tester.runAsync(() => notifier.checkAuth());

      expect(notifier.state.isLoading, false);
      expect(notifier.state.action, SplashAction.goToHome);
    });

    testWidgets('checkAuth() with invalid onboarding value → goToOnboarding',
        (tester) async {
      final notifier = _createNotifier();
      _mockStorageValues = {
        StorageKeys.hasSeenOnboarding: 'false',
      };

      await tester.runAsync(() => notifier.checkAuth());

      // 'false' != 'true', so hasSeenOnboarding returns false → goToOnboarding
      expect(notifier.state.action, SplashAction.goToOnboarding);
    });

    testWidgets('checkAuth() with storage exception → goToLogin fallback',
        (tester) async {
      final notifier = _createNotifier();

      // Remove both channel mocks to trigger MissingPluginException
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

      await tester.runAsync(() => notifier.checkAuth());

      expect(notifier.state.isLoading, false);
      expect(notifier.state.action, SplashAction.goToLogin);
      // tearDown handles cleanup — no manual restore needed
    });
  });
}
