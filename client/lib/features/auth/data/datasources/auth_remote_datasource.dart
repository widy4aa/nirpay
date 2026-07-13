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
    return response.data;
  }

  Future<Map<String, dynamic>> checkUsername(String username) async {
    final response = await _dio.get('/auth/check-username/$username');
    return response.data['data'];
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> params) async {
    final response = await _dio.post('/auth/register', data: params);
    return response.data['data'];
  }

  Future<Map<String, dynamic>> login(String email, String pin) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'pin': pin},
    );
    return response.data['data'];
  }
}
