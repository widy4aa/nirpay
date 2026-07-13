import 'package:dio/dio.dart';

class WalletRemoteDatasource {
  final Dio _dio;

  WalletRemoteDatasource(this._dio);

  Future<Map<String, dynamic>> getBalance() async {
    final response = await _dio.get('/wallet/balance');
    return response.data['data'];
  }

  Future<Map<String, dynamic>> resolveUsername(String username) async {
    final response = await _dio.get('/wallet/resolve/$username');
    return response.data['data'];
  }
}
