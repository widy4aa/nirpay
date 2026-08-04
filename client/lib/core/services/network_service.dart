import 'dart:async';
import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

final networkServiceProvider = Provider<NetworkService>((ref) {
  final config = ref.watch(appConfigProvider);
  return NetworkService(config.apiBaseUrl);
});

final networkConnectivityProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(networkServiceProvider);
  return service.onConnectivityChanged;
});

class NetworkService {
  final Connectivity _connectivity = Connectivity();
  final String _apiBaseUrl;
  final Dio _dio;

  NetworkService(this._apiBaseUrl) : _dio = Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 3);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
  }

  Stream<bool> get onConnectivityChanged async* {
    // Check awal
    yield await isConnected();

    // 1. Pantau perubahan jaringan level OS
    final connectivityStream = _connectivity.onConnectivityChanged;
    // 2. Pantau secara berkala tiap 5 detik
    final tickerStream = Stream.periodic(const Duration(seconds: 5));

    // Gabungkan trigger dari perubahan OS dan dari timer
    await for (final _ in StreamGroup.merge([connectivityStream, tickerStream])) {
      yield await isConnected();
    }
  }

  /// Cek apakah SERVER BACKEND bisa dijangkau
  Future<bool> isConnected() async {
    try {
      // Ping ke endpoint health check atau root API
      // Ubah dari /api ke root jika perlu, tapi request GET sederhana cukup
      final response = await _dio.get(_apiBaseUrl.replaceAll('/api', '/up'));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
