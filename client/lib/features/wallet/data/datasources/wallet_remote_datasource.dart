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

  /// Ambil daftar transaksi dari server
  Future<List<dynamic>> getTransactions() async {
    final response = await _dio.get('/wallet/transactions');
    return response.data['data'] as List;
  }

  /// Request top up
  Future<Map<String, dynamic>> topUp(int amountCent) async {
    final response = await _dio.post('/wallet/topup', data: {
      'amountCent': amountCent,
    });
    return response.data['data'] as Map<String, dynamic>;
  }

  /// Request withdraw
  Future<Map<String, dynamic>> withdraw({
    required int amountCent,
    required String method,
    required String accountNumber,
  }) async {
    final response = await _dio.post('/wallet/withdraw', data: {
      'amountCent': amountCent,
      'method': method,
      'accountNumber': accountNumber,
    });
    return response.data['data'] as Map<String, dynamic>;
  }

  /// Push transaksi PENDING ke server, terima konfirmasi + balance baru
  Future<Map<String, dynamic>> syncTransactions(
    List<Map<String, dynamic>> transactions,
  ) async {
    final response = await _dio.post(
      '/wallet/sync',
      data: {'transactions': transactions},
    );
    return response.data['data'];
  }
}
