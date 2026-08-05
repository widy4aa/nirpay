import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Resolver untuk menentukan backend URL yang aktif.
/// Mencoba beberapa URL secara berurutan, gunakan yang pertama berhasil.
class BackendResolver {
  static const List<String> _backendUrls = [
    'http://10.161.163.215:3001/api',            // IP lokal (cepat)
    'http://nirpay-backend.widy4aa.my.id/api',   // Domain (fallback)
  ];

  static String? _resolvedUrl;
  static final Logger _logger = Logger();

  /// Mendapatkan backend URL yang aktif.
  /// Akan mencoba resolve jika belum ada yang tersimpan.
  static Future<String> resolve() async {
    if (_resolvedUrl != null) return _resolvedUrl!;

    for (final url in _backendUrls) {
      _logger.d('[Backend] Trying: $url');
      try {
        final dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ));

        // Coba ping endpoint /up atau /api/auth/check-username/test
        final response = await dio.get(
          '$url/../up',
          options: Options(validateStatus: (_) => true),
        );

        if (response.statusCode != null && response.statusCode! < 500) {
          _resolvedUrl = url;
          _logger.d('[Backend] Resolved: $url');
          return url;
        }
      } catch (e) {
        _logger.d('[Backend] Failed: $url ($e)');
      }
    }

    // Fallback: gunakan yang pertama
    _resolvedUrl = _backendUrls.first;
    _logger.d('[Backend] Using fallback: $_resolvedUrl');
    return _resolvedUrl!;
  }

  /// Reset resolved URL (misalnya saat ganti network)
  static void reset() {
    _resolvedUrl = null;
  }

  /// Cek apakah backend yang aktif adalah domain
  static bool get isUsingDomain =>
      _resolvedUrl?.contains('nirpay-backend.widy4aa.my.id') ?? false;
}
