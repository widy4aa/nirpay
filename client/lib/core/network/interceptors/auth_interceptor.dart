import 'package:dio/dio.dart';
import '../../services/secure_storage_service.dart';

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
      final preview = token.length > 20 ? token.substring(0, 20) : token;
      print('🔑 [Auth] Attaching token: $preview...');
    } else {
      print('🔑 [Auth] No access_token found in storage');
    }
    handler.next(options);
  }
}
