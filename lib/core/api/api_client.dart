import 'package:dio/dio.dart';
import 'api_constants.dart';

/// Singleton Dio HTTP client configured for the TrySomething API.
class ApiClient {
  static Dio? _instance;

  static Dio get instance => _instance ??= _create();

  static Dio _create() {
    return Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  ApiClient._();
}
