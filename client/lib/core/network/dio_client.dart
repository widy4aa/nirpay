import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';
import '../providers/app_providers.dart';
import '../services/app_logger.dart';
import '../services/secure_storage_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';
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
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Custom logger — tampil rapi di debug mode
    if (kDebugMode) {
      dio.interceptors.add(LoggerInterceptor(logger));
    }

    dio.interceptors.add(AuthInterceptor(storage));
    dio.interceptors.add(TokenInterceptor(logger, storage, dio));

    return DioClient._(dio);
  }
}

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final logger = ref.watch(appLoggerProvider);
  final storage = ref.watch(secureStorageProvider);

  return DioClient.create(config, logger, storage).dio;
});
