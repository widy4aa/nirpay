import 'package:dio/dio.dart';

class UploadService {
  final Dio _dio;

  UploadService(this._dio);

  Future<String> uploadKtp(String filePath) async {
    final formData = FormData.fromMap({
      'ktpPhoto': await MultipartFile.fromFile(
        filePath,
        filename: 'ktp.jpg',
      ),
    });

    final response = await _dio.post('/upload/ktp', data: formData);
    return response.data['data']['url'] as String;
  }

  Future<String> uploadSelfie(String filePath) async {
    final formData = FormData.fromMap({
      'selfiePhoto': await MultipartFile.fromFile(
        filePath,
        filename: 'selfie.jpg',
      ),
    });

    final response = await _dio.post('/upload/selfie', data: formData);
    return response.data['data']['url'] as String;
  }

  Future<String> uploadProfilePhoto(String filePath) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(
        filePath,
        filename: 'profile.jpg',
      ),
    });

    final response = await _dio.post('/profile/photo', data: formData);
    return response.data['data']['url'] as String;
  }
}
