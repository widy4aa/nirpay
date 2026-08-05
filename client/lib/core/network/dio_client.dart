import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';
import '../config/backend_resolver.dart';
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
    String baseUrl,
    Logger logger,
    SecureStorageService storage,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
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

/// Provider untuk resolve backend URL (async)
final backendUrlProvider = FutureProvider<String>((ref) async {
  return BackendResolver.resolve();
});

/// Provider untuk Dio client (depends on backendUrlProvider)
final dioProvider = Provider<Dio>((ref) {
  final logger = ref.watch(appLoggerProvider);
  final storage = ref.watch(secureStorageProvider);

  // Watch backend URL resolution
  final backendUrlAsync = ref.watch(backendUrlProvider);

  return backendUrlAsync.when(
    data: (baseUrl) => DioClient.create(baseUrl, logger, storage).dio,
    loading: () {
      // Fallback: gunakan config default sambil resolve
      final config = ref.read(appConfigProvider);
      return DioClient.create(config.apiBaseUrl, logger, storage).dio;
    },
    error: (_, __) {
      // Fallback: gunakan config default
      final config = ref.read(appConfigProvider);
      return DioClient.create(config.apiBaseUrl, logger, storage).dio;
    },
  );
});
