import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider untuk menyimpan dan membaca waktu sync terakhir
final lastSyncProvider = StateNotifierProvider<LastSyncNotifier, DateTime?>((ref) {
  return LastSyncNotifier();
});

class LastSyncNotifier extends StateNotifier<DateTime?> {
  LastSyncNotifier() : super(null) {
    _loadLastSync();
  }

  Future<void> _loadLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('last_sync_timestamp');
    if (timestamp != null) {
      state = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
  }

  Future<void> updateLastSync() async {
    final now = DateTime.now();
    state = now;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_sync_timestamp', now.millisecondsSinceEpoch);
  }
}
