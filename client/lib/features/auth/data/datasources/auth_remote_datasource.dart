import 'package:dio/dio.dart';

class AuthRemoteDatasource {
  final Dio _dio;

  AuthRemoteDatasource(this._dio);

  Future<Map<String, dynamic>> checkAvailability(
    String email,
    String phone,
  ) async {
    final response = await _dio.post(
      '/auth/check-availability',
      data: {'email': email, 'phone': phone},
    );
    return response.data['data'];
  }

  Future<Map<String, dynamic>> sendOtp(
    String email,
    String phone,
    String type,
  ) async {
    final response = await _dio.post(
      '/auth/send-otp',
      data: {'email': email, 'phone': phone, 'type': type},
    );
    return response.data['data'];
  }

  Future<Map<String, dynamic>> verifyOtp(String otpId, String otpCode) async {
    final response = await _dio.post(
      '/auth/verify-otp',
      data: {'otpId': otpId, 'otpCode': otpCode},
    );
    return response.data['data'];
  }

  Future<Map<String, dynamic>> checkUsername(String username) async {
    final response = await _dio.get('/auth/check-username/$username');
    return response.data['data'];
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> params) async {
    final response = await _dio.post('/auth/register', data: params);
    return response.data['data'];
  }

  Future<({Map<String, dynamic> tokens, Map<String, dynamic> user, bool deviceChanged})> login(
    String email,
    String password, {
    String? deviceId,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
        if (deviceId != null) 'deviceId': deviceId,
      },
    );
    final data = response.data['data'];
    return (
      tokens: {
        'accessToken': data['accessToken'],
        'refreshToken': data['refreshToken'],
      },
      user: data['user'] as Map<String, dynamic>,
      deviceChanged: (data['deviceChanged'] as bool?) ?? false,
    );
  }

  Future<({
    String accessToken,
    String refreshToken,
    Map<String, dynamic> user,
  })> verifyPin(
    String pin,
    String refreshToken,
  ) async {
    final response = await _dio.post(
      '/auth/verify-pin',
      data: {'pin': pin},
      options: Options(
        headers: {'Authorization': 'Bearer $refreshToken'},
      ),
    );
    final data = response.data['data'];
    return (
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      user: data['user'] as Map<String, dynamic>,
    );
  }

  /// Update profile ke server
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.post(
      '/profile/update',
      data: data,
    );
    return response.data['data'] as Map<String, dynamic>;
  }
}