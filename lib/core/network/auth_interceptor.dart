import 'package:dio/dio.dart';
import '../services/token_service.dart';
import '../constants/api_constants.dart';

/// Injects JWT access token into requests and handles 401 refresh flow.
class AuthInterceptor extends Interceptor {
  final TokenService _tokenService;
  bool _isRefreshing = false;

  AuthInterceptor({required TokenService tokenService})
      : _tokenService = tokenService;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshed = await _tokenService.refreshToken();
        if (refreshed != null) {
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $refreshed';
          final response = await Dio().fetch(retryOptions);
          handler.resolve(response);
          return;
        }
      } catch (_) {
        // Refresh failed — clear tokens
        await _tokenService.clearTokens();
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }
}
