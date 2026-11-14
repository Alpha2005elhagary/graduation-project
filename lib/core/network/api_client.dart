import 'package:dio/dio.dart';
import 'package:breakbot/core/constants/app_constants.dart';
import 'package:breakbot/core/storage/secure_storage.dart';
import 'package:logger/logger.dart';

class ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger();
  final SecureStorage _secureStorage;

  ApiClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.defaultTimeout,
        receiveTimeout: AppConstants.defaultTimeout,
        sendTimeout: AppConstants.defaultTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Language': 'ar',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          _logger.d('${options.method} ${options.uri}');
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token refresh handled by repository layer
            return handler.next(error);
          }
          _logger.e('API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
