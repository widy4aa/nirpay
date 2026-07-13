import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../services/secure_storage_service.dart';

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
