import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cfpv/core/network/dio_client.dart';
import 'package:cfpv/core/services/token_service.dart';
import 'package:cfpv/core/services/secure_storage_service.dart';

/// Configurable storage values for flutter_secure_storage method channel mock.
Map<String, String?> _mockStorageValues = {};

/// Interceptor that returns mock responses for the refresh-token API call.
class _MockDioInterceptor extends Interceptor {
  final bool shouldThrow;

  _MockDioInterceptor({this.shouldThrow = false});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (shouldThrow) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          message: 'Refresh failed',
        ),
      );
    } else {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'accessToken': 'new-access-token',
            'refreshToken': 'new-refresh-token',
          },
        ),
      );
    }
  }
}

void main() {
  setUp(() {
    _mockStorageValues = {};

    /// Shared handler for flutter_secure_storage method channel (v9+).
    Future<dynamic> mockHandler(MethodCall methodCall) async {
      final args = methodCall.arguments;
      final map = (args is Map) ? Map<String, dynamic>.from(args) : null;
      switch (methodCall.method) {
        case 'read':
          return map?['key'] != null ? _mockStorageValues[map!['key']] : null;
        case 'write':
          if (map?.containsKey('key') == true) {
            _mockStorageValues[map!['key'] as String] =
                map['value'] as String?;
          }
          return true;
        case 'containsKey':
          return map?['key'] != null &&
              _mockStorageValues.containsKey(map!['key']);
        case 'delete':
          if (map?.containsKey('key') == true) {
            _mockStorageValues.remove(map!['key'] as String);
          }
          return true;
        case 'deleteAll':
          _mockStorageValues.clear();
          return true;
        case 'readAll':
          return Map<String, String>.from(_mockStorageValues);
        default:
          return null;
      }
    }

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

  TokenService createService({bool refreshShouldThrow = false}) {
    final dioClient = DioClient.create(
      baseUrl: 'http://test.local',
      interceptors: [
        _MockDioInterceptor(shouldThrow: refreshShouldThrow),
      ],
    );
    return TokenService(
      storage: SecureStorageService(),
      dioClient: dioClient,
    );
  }

  group('TokenService', () {
    group('getAccessToken()', () {
      testWidgets('returns stored token', (tester) async {
        _mockStorageValues = {'cfpv_access_token': 'my-access-token'};
        final service = createService();

        final token = await tester.runAsync(() => service.getAccessToken());

        expect(token, 'my-access-token');
      });

      testWidgets('returns null when no token stored', (tester) async {
        _mockStorageValues = {};
        final service = createService();

        final token = await tester.runAsync(() => service.getAccessToken());

        expect(token, isNull);
      });
    });

    group('setTokens()', () {
      testWidgets('stores both access and refresh tokens', (tester) async {
        final service = createService();

        await tester.runAsync(
          () => service.setTokens('access-123', 'refresh-456'),
        );

        expect(_mockStorageValues['cfpv_access_token'], 'access-123');
        expect(_mockStorageValues['cfpv_refresh_token'], 'refresh-456');
      });
    });

    group('hasValidToken()', () {
      testWidgets('returns true when access token exists', (tester) async {
        _mockStorageValues = {'cfpv_access_token': 'my-access-token'};
        final service = createService();

        final valid = await tester.runAsync(() => service.hasValidToken());

        expect(valid, isTrue);
      });

      testWidgets('returns false when no token exists', (tester) async {
        _mockStorageValues = {};
        final service = createService();

        final valid = await tester.runAsync(() => service.hasValidToken());

        expect(valid, isFalse);
      });
    });

    group('clearTokens()', () {
      testWidgets('removes both access and refresh tokens', (tester) async {
        _mockStorageValues = {
          'cfpv_access_token': 'access-123',
          'cfpv_refresh_token': 'refresh-456',
        };
        final service = createService();

        await tester.runAsync(() => service.clearTokens());

        expect(_mockStorageValues['cfpv_access_token'], isNull);
        expect(_mockStorageValues['cfpv_refresh_token'], isNull);
      });
    });

    group('refreshToken()', () {
      testWidgets('returns null when no refresh token stored',
          (tester) async {
        _mockStorageValues = {};
        final service = createService();

        final result = await tester.runAsync(() => service.refreshToken());

        expect(result, isNull);
        // No API call was made — tokens remain empty
        expect(_mockStorageValues['cfpv_access_token'], isNull);
      });

      testWidgets('returns new access token and updates storage on success',
          (tester) async {
        _mockStorageValues = {'cfpv_refresh_token': 'old-refresh-token'};
        final service = createService(refreshShouldThrow: false);

        final result = await tester.runAsync(() => service.refreshToken());

        expect(result, 'new-access-token');
        expect(_mockStorageValues['cfpv_access_token'], 'new-access-token');
        expect(_mockStorageValues['cfpv_refresh_token'], 'new-refresh-token');
      });

      testWidgets('clears tokens on DioException and returns null',
          (tester) async {
        _mockStorageValues = {
          'cfpv_access_token': 'old-access-token',
          'cfpv_refresh_token': 'old-refresh-token',
        };
        final service = createService(refreshShouldThrow: true);

        final result = await tester.runAsync(() => service.refreshToken());

        expect(result, isNull);
        // Tokens cleared on DioException
        expect(_mockStorageValues['cfpv_access_token'], isNull);
        expect(_mockStorageValues['cfpv_refresh_token'], isNull);
      });
    });
  });
}
