import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/wallet/data/services/wallet_sync_service.dart';
import '../../features/sync/presentation/providers/last_sync_provider.dart';
import '../services/secure_storage_service.dart';

/// Service untuk auto-sync dengan debounce.
/// Trigger: login, connectivity change, app resume.
class AutoSyncService {
  final WalletSyncService _syncService;
  final SecureStorageService _storage;
  final Connectivity _connectivity;
  final VoidCallback? _onSyncSuccess;

  Timer? _debounceTimer;
  bool _isSyncing = false;
  bool _wasOffline = true; // Asumsi awal offline
  DateTime? _lastSyncTime;

  // Debounce duration
  static const _debounceDuration = Duration(seconds: 30);

  // Minimum interval antara sync
  static const _minSyncInterval = Duration(seconds: 30);

  AutoSyncService(this._syncService, this._storage, this._connectivity, {VoidCallback? onSyncSuccess})
      : _onSyncSuccess = onSyncSuccess;

  /// Inisialisasi listener untuk connectivity dan app lifecycle
  void initialize() {
    // Listen perubahan koneksi
    _connectivity.onConnectivityChanged.listen((results) {
      final isConnected = results.isNotEmpty &&
          !results.every((r) => r == ConnectivityResult.none);

      if (isConnected && _wasOffline) {
        // Baru online dari offline → trigger sync
        debugPrint('🔄 [AutoSync] Online detected — scheduling sync');
        _scheduleSync(trigger: 'connectivity');
      }

      _wasOffline = !isConnected;
    });

    debugPrint('🔄 [AutoSync] Initialized');
  }

  /// Trigger sync setelah login berhasil
  void onLoginSuccess() {
    debugPrint('🔄 [AutoSync] Login success — scheduling sync');
    _scheduleSync(trigger: 'login', force: true);
  }

  /// Trigger sync saat app resume dari background
  void onAppResume() {
    debugPrint('🔄 [AutoSync] App resume — scheduling sync');
    _scheduleSync(trigger: 'resume');
  }

  /// Schedule sync dengan debounce
  void _scheduleSync({required String trigger, bool force = false}) {
    // Cek apakah user sudah login (ada token)
    _checkAndSync(trigger, force);
  }

  Future<void> _checkAndSync(String trigger, bool force) async {
    // Cek token valid
    final token = await _storage.read('access_token');
    if (token == null || token == 'offline_token' || token == 'seeded_token') {
      debugPrint('🔄 [AutoSync] Skipping — no valid token');
      return;
    }

    // Debounce: batalkan timer sebelumnya
    _debounceTimer?.cancel();

    if (force) {
      // Force: langsung sync (untuk login)
      await _doSync(trigger);
    } else {
      // Debounce: tunggu 30 detik sebelum sync
      _debounceTimer = Timer(_debounceDuration, () async {
        await _doSync(trigger);
      });
    }
  }

  Future<void> _doSync(String trigger) async {
    // Cek minimum interval
    if (_lastSyncTime != null) {
      final elapsed = DateTime.now().difference(_lastSyncTime!);
      if (elapsed < _minSyncInterval) {
        debugPrint('🔄 [AutoSync] Skipping — last sync ${elapsed.inSeconds}s ago (min: ${_minSyncInterval.inSeconds}s)');
        return;
      }
    }

    // Cek apakah sedang sync
    if (_isSyncing) {
      debugPrint('🔄 [AutoSync] Skipping — already syncing');
      return;
    }

    _isSyncing = true;
    debugPrint('🔄 [AutoSync] Starting sync (trigger: $trigger)');

    try {
      await _syncService.fullSync();
      _lastSyncTime = DateTime.now();
      debugPrint('🔄 [AutoSync] Sync completed (trigger: $trigger)');

      // Callback untuk update UI (last sync time)
      _onSyncSuccess?.call();
    } catch (e) {
      debugPrint('🔄 [AutoSync] Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Force sync (abaikan debounce, untuk pull-to-refresh)
  Future<void> forceSync() async {
    _debounceTimer?.cancel();
    await _doSync('manual');
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}

final autoSyncServiceProvider = Provider<AutoSyncService>((ref) {
  final syncService = ref.watch(walletSyncServiceProvider);
  final storage = ref.watch(secureStorageProvider);
  final connectivity = Connectivity();

  final service = AutoSyncService(
    syncService,
    storage,
    connectivity,
    onSyncSuccess: () {
      // Update last sync time di provider
      try {
        ref.read(lastSyncProvider.notifier).updateLastSync();
      } catch (_) {}
    },
  );
  service.initialize();

  ref.onDispose(() => service.dispose());

  return service;
});
