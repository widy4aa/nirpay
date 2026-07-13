import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../providers/app_providers.dart';
import '../services/app_logger.dart';
import '../services/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read('access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class TokenInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Logger _logger;

  TokenInterceptor(this._storage, this._logger);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      _logger.d('[Network] 401 Unauthorized, attempting to refresh token');

      try {
        final refreshToken = await _storage.read('refresh_token');
        if (refreshToken != null) {
          // Note: In a real app, you would call a refresh endpoint here.
          // For now, if we can't refresh, just clear tokens.
          // final response = await _dio.post('/auth/refresh', data: {'token': refreshToken});
          // final newToken = response.data['data']['access_token'];
          // await _storage.write('access_token', newToken);

          // err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          // final retryResponse = await _dio.fetch(err.requestOptions);
          // return handler.resolve(retryResponse);

          _logger.e('[Network] Refresh logic not implemented yet');
          await _storage.delete('access_token');
          await _storage.delete('refresh_token');
        }
      } catch (e) {
        _logger.e('[Network] Failed to refresh token', error: e);
      }
    }
    handler.next(err);
  }
}

class DioClient {
  DioClient._(this.dio);

  final Dio dio;

  factory DioClient.create(
    AppConfig config,
    Logger logger,
    SecureStorageService storage,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: AppConstants.networkTimeout,
        receiveTimeout: AppConstants.networkTimeout,
      ),
    );

    if (kDebugMode && config.enableNetworkLogs) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    dio.interceptors.add(AuthInterceptor(storage));
    dio.interceptors.add(TokenInterceptor(storage, logger));

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          logger.e(
            '[Network] Dio error',
            error: error,
            stackTrace: error.stackTrace,
          );
          handler.next(error);
        },
      ),
    );

    return DioClient._(dio);
  }
}

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final logger = ref.watch(appLoggerProvider);
  final storage = ref.watch(secureStorageProvider);

  return DioClient.create(config, logger, storage).dio;
});
