import 'package:dio/dio.dart';
import 'token_storage.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';

/// Dio interceptor that attaches JWT tokens and handles auto-refresh on 401.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Don't try to refresh if we're already on an auth endpoint
    final path = err.requestOptions.path;
    if (path.startsWith('/auth/')) {
      handler.next(err);
      return;
    }

    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) {
      handler.next(err);
      return;
    }

    try {
      // Use a separate Dio instance to avoid interceptor loop
      final refreshDio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await refreshDio.post(
        ApiConstants.authRefresh,
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['accessToken'] as String;
      final newRefreshToken = response.data['refreshToken'] as String;
      await TokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      // Retry original request with new token
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await ApiClient.instance.fetch(err.requestOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      // Refresh failed — clear tokens and propagate error
      await TokenStorage.clearTokens();
      handler.next(err);
    }
  }
}
