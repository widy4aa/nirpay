import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../providers/app_providers.dart';
import '../services/app_logger.dart';
import '../services/secure_storage_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/token_interceptor.dart';

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
