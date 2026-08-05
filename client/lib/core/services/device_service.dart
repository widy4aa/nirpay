import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Service untuk mengelola device ID unik per installasi.
/// Device ID digunakan untuk binding satu device satu akun.
class DeviceService {
  static const _key = 'device_id';
  final SharedPreferences _prefs;

  DeviceService(this._prefs);

  /// Mendapatkan device ID unik.
  /// Jika belum ada, generate baru dan simpan.
  String getDeviceId() {
    var deviceId = _prefs.getString(_key);
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      _prefs.setString(_key, deviceId);
    }
    return deviceId;
  }

  /// Reset device ID (untuk testing atau logout)
  Future<void> resetDeviceId() async {
    await _prefs.remove(_key);
  }
}

final deviceServiceProvider = Provider<DeviceService>((ref) {
  // SharedPreferences sudah di-override di main.dart
  throw UnimplementedError('DeviceService harus di-override');
});
