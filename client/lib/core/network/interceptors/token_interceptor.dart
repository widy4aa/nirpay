import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../services/secure_storage_service.dart';

class TokenInterceptor extends Interceptor {
  final Logger _logger;
  final SecureStorageService _storage;
  final Dio _dio;

  bool _isRefreshing = false;

  TokenInterceptor(this._logger, this._storage, this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _logger.d('[Token] 401 detected — attempting token refresh');
      _isRefreshing = true;

      try {
        final refreshToken = await _storage.read('refresh_token');
        final accessToken = await _storage.read('access_token');
        final accessPreview = (accessToken != null && accessToken.length > 20)
            ? accessToken.substring(0, 20) : accessToken;
        final refreshPreview = (refreshToken != null && refreshToken.length > 20)
            ? refreshToken.substring(0, 20) : refreshToken;
        _logger.d('[Token] Stored access_token: ${accessPreview ?? "null"}...');
        _logger.d('[Token] Stored refresh_token: ${refreshPreview ?? "null"}...');
        if (refreshToken == null) {
          _logger.d('[Token] No refresh token available');
          _isRefreshing = false;
          handler.next(err);
          return;
        }

        // Call refresh endpoint (gunakan Dio baru tanpa interceptor untuk hindari loop)
        final refreshDio = Dio(BaseOptions(
          baseUrl: _dio.options.baseUrl,
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        ));

        final response = await refreshDio.post(
          '/auth/refresh',
          options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
        );

        final data = response.data['data'];
        final newAccessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String;

        // Simpan token baru
        await _storage.write('access_token', newAccessToken);
        await _storage.write('refresh_token', newRefreshToken);
        _logger.d('[Token] Token refreshed successfully');

        // Retry request asli dengan token baru
        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        final retryResponse = await _dio.fetch(requestOptions);
        _isRefreshing = false;
        handler.resolve(retryResponse);
        return;
      } catch (e) {
        _logger.e('[Token] Refresh failed: $e');
        _isRefreshing = false;
        // Refresh gagal — pass through error asli
      }
    }

    handler.next(err);
  }
}
