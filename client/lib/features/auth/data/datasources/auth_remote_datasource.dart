import 'package:dio/dio.dart';

class AuthRemoteDatasource {
  final Dio _dio;

  AuthRemoteDatasource(this._dio);

  Future<Map<String, dynamic>> login(String email, String pin) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'pin': pin},
    );
    return response.data['data'];
  }

  Future<bool> checkAvailability(String email, String phone) async {
    final response = await _dio.post(
      '/auth/check-availability',
      data: {'email': email, 'phone': phone},
    );
    return response.data['data']['emailAvailable'] == true &&
        response.data['data']['phoneAvailable'] == true;
  }

  Future<String> sendOtp(String email, String phone) async {
    final response = await _dio.post(
      '/auth/send-otp',
      data: {'email': email, 'phone': phone, 'type': 'register'},
    );
    return response.data['data']['otpId'];
  }

  Future<bool> verifyOtp(String otpId, String otpCode) async {
    final response = await _dio.post(
      '/auth/verify-otp',
      data: {'otpId': otpId, 'otpCode': otpCode},
    );
    return response.data['success'] == true;
  }

  Future<bool> checkUsername(String username) async {
    final response = await _dio.get('/auth/check-username/$username');
    return response.data['data']['available'] == true;
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String phone,
    required String username,
    required String fullName,
    required String pin,
    required String publicKeyB64,
  }) async {
    final response = await _dio.post(
      '/auth/register',
      data: {
        'email': email,
        'phone': phone,
        'username': username,
        'fullName': fullName,
        'pin': pin,
        'publicKeyB64': publicKeyB64,
      },
    );
    return response.data['data'];
  }
}
