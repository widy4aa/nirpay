import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:drift/drift.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/app_logger.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../auth/data/datasources/user_local_datasource.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/user_local_provider.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletSyncService {
  final WalletRemoteDatasource _remoteDatasource;
  final AuthRemoteDatasource _authRemoteDatasource;
  final UserLocalDatasource _userLocalDatasource;
  final AppDatabase _db;
  final Logger _logger;
  final SecureStorageService _storage;

  WalletSyncService(this._remoteDatasource, this._authRemoteDatasource, this._userLocalDatasource, this._db, this._logger, this._storage);

  /// Full sync: PUSH transaksi PENDING ke server, lalu PULL balance terbaru.
  /// Jika tidak ada transaksi pending, cukup pull balance.
  Future<Map<String, dynamic>?> fullSync() async {
    try {
      _logger.d('[Sync] Starting full sync...');

      // Cek apakah token valid (bukan offline/dummy)
      final accessToken = await _storage.read('access_token');
      if (accessToken == null || accessToken == 'offline_token' || accessToken == 'seeded_token') {
        _logger.d('[Sync] Skipping sync — offline mode (no valid token)');
        return null;
      }

      // 0. Push dirty profile ke server
      await _pushDirtyProfile();

      // Ambil user ID dari local DB
      final activeUser = await _db.getActiveUser();
      if (activeUser == null) {
        _logger.e('[Sync] No active user found');
        return null;
      }
      final userId = activeUser.id;

      // 1. Ambil transaksi PENDING dari local DB
      final pendingTxs = await _getPendingTransactions(userId);
      _logger.d('[Sync] Found ${pendingTxs.length} pending transactions');

      Map<String, dynamic> serverBalance;

      if (pendingTxs.isNotEmpty) {
        // 2. PUSH: Kirim transaksi PENDING ke server
        _logger.d('[Sync] Pushing ${pendingTxs.length} transactions to server...');
        final result = await _remoteDatasource.syncTransactions(pendingTxs);

        final synced = (result['synced'] as List?) ?? [];
        final rejected = (result['rejected'] as List?) ?? [];

        _logger.d('[Sync] Server response: ${synced.length} synced, ${rejected.length} rejected');

        // 3. Update local: tandai transaksi yang sudah di-sync
        for (final tx in synced) {
          final txId = tx['txId'] as String;
          await _markTransactionSynced(txId);
          _logger.d('[Sync] Marked $txId as SYNCED');
        }

        // Tandai transaksi yang di-reject
        for (final tx in rejected) {
          final txId = tx['txId'] as String;
          final reason = tx['reason'] as String? ?? 'UNKNOWN';
          await _markTransactionRejected(txId, reason);
          _logger.d('[Sync] Marked $txId as REJECTED: $reason');
        }

        serverBalance = result['balance'] as Map<String, dynamic>;
      } else {
        // Tidak ada pending, cukup pull balance
        _logger.d('[Sync] No pending transactions, pulling balance...');
        serverBalance = await _remoteDatasource.getBalance();
      }

      // 4. Update local balance dari server
      final existingBalance = await _db.getWalletBalance(userId);
      final maxHop = _parseInt(serverBalance['maxHop']) > 0
          ? _parseInt(serverBalance['maxHop'])
          : existingBalance?.maxHop ?? 3;

      await _db.into(_db.walletBalances).insertOnConflictUpdate(
        WalletBalancesCompanion(
          id: Value('wallet-$userId'),
          userId: Value(userId),
          amountCent: Value(_parseInt(serverBalance['amountCent'])),
          reservedCent: Value(_parseInt(serverBalance['reservedCent'])),
          currency: Value(serverBalance['currency'] ?? 'IDR'),
          maxHop: Value(maxHop),
          hopCount: const Value(0), // Reset hop setelah sync
        ),
      );

      // 5. Pull transaksi dari server dan sync ke local DB
      await _pullTransactionsFromServer(userId);

      // Debug: tampilkan status transaksi setelah sync
      final allTxs = await (_db.select(_db.transactions)).get();
      for (final tx in allTxs) {
        _logger.d('[Sync] Local TX: ${tx.txId} | ${tx.direction} | ${tx.txType} | ${tx.amountCent} | ${tx.syncStatus}');
      }

      _logger.d('[Sync] Full sync completed. Balance updated, hop reset to 0');
      return serverBalance;
    } catch (e) {
      _logger.e('[Sync] Full sync failed', error: e);
      rethrow;
    }
  }

  /// Push user profile yang dirty ke server
  Future<void> _pushDirtyProfile() async {
    try {
      final dirtyUsers = await _userLocalDatasource.getDirtyUsers();
      if (dirtyUsers.isEmpty) return;

      _logger.d('[Sync] Found ${dirtyUsers.length} dirty profile(s) to push');

      for (final user in dirtyUsers) {
        final data = <String, dynamic>{};
        if (user.fullName.isNotEmpty) data['fullName'] = user.fullName;
        if (user.phone != null && user.phone!.isNotEmpty) data['phone'] = user.phone;
        if (user.province != null) data['province'] = user.province;
        if (user.city != null) data['city'] = user.city;
        if (user.district != null) data['district'] = user.district;
        if (user.village != null) data['village'] = user.village;
        if (user.postalCode != null) data['postalCode'] = user.postalCode;
        if (user.rt != null) data['rt'] = user.rt;
        if (user.rw != null) data['rw'] = user.rw;

        if (data.isEmpty) {
          await _userLocalDatasource.markUserClean(user.id);
          continue;
        }

        await _authRemoteDatasource.updateProfile(data);
        await _userLocalDatasource.markUserClean(user.id);
        _logger.d('[Sync] Profile pushed for user: ${user.id}');
      }
    } catch (e) {
      _logger.e('[Sync] Failed to push dirty profile', error: e);
      // Tidak throw — sync lainnya tetap jalan
    }
  }

  /// Parse value ke int (handle String atau num)
  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Tarik transaksi dari server dan merge ke local DB
  Future<void> _pullTransactionsFromServer(String userId) async {
    try {
      final serverTxs = await _remoteDatasource.getTransactions();
      _logger.d('[Sync] Pulled ${serverTxs.length} transactions from server');

      for (final tx in serverTxs) {
        final txId = tx['txId'] as String;
        final exists = await (_db.select(_db.transactions)
              ..where((t) => t.txId.equals(txId))
              ..limit(1))
            .getSingleOrNull();

        if (exists == null) {
          // Transaksi baru dari server, simpan ke local DB
          await _db.insertTransaction(
            TransactionsCompanion(
              id: Value(txId),
              txId: Value(txId),
              direction: Value(tx['direction'] as String),
              txType: Value(tx['txType'] as String),
              amountCent: Value(_parseInt(tx['amountCent'])),
              hopCount: Value(_parseInt(tx['hopCount'])),
              syncStatus: const Value('SYNCED'),
              counterpartyName: Value(tx['counterpartyName'] as String?),
              counterpartyId: Value(tx['counterpartyId'] as String?),
            ),
          );
          _logger.d('[Sync] Pulled new tx: $txId');
        } else if (exists.syncStatus != 'SYNCED' && (tx['syncStatus'] as String) == 'SYNCED') {
          // Update status jika server sudah SYNCED tapi local masih PENDING
          await _markTransactionSynced(txId);
          _logger.d('[Sync] Updated tx status: $txId → SYNCED');
        }
      }
    } catch (e) {
      _logger.e('[Sync] Failed to pull transactions', error: e);
      // Tidak throw — sync balance tetap berhasil meskipun pull transaksi gagal
    }
  }

  /// Ambil transaksi yang masih PENDING dari local DB
  Future<List<Map<String, dynamic>>> _getPendingTransactions(String userId) async {
    final pending = await (_db.select(_db.transactions)
          ..where((t) => t.syncStatus.equals('PENDING')))
        .get();

    return pending.map((tx) => {
      'txId': tx.txId,
      'direction': tx.direction,
      'txType': tx.txType,
      'amountCent': tx.amountCent,
      'hopCount': tx.hopCount,
      'counterpartyName': tx.counterpartyName,
    }).toList();
  }

  /// Tandai transaksi sebagai SYNCED di local DB
  Future<void> _markTransactionSynced(String txId) async {
    await (_db.update(_db.transactions)
          ..where((t) => t.txId.equals(txId)))
        .write(
      const TransactionsCompanion(
        syncStatus: Value('SYNCED'),
      ),
    );
  }

  /// Tandai transaksi sebagai REJECTED di local DB
  Future<void> _markTransactionRejected(String txId, String reason) async {
    await (_db.update(_db.transactions)
          ..where((t) => t.txId.equals(txId)))
        .write(
      TransactionsCompanion(
        syncStatus: const Value('REJECTED'),
        // Note: kolom reject_reason belum ada di schema client
        // Bisa ditambahkan nanti jika perlu
      ),
    );
  }

  /// Legacy: pull balance only (untuk backward compatibility)
  Future<void> syncBalance() async {
    await fullSync();
  }
}

final walletRemoteDatasourceProvider = Provider<WalletRemoteDatasource>((ref) {
  return WalletRemoteDatasource(ref.watch(dioProvider));
});

final walletSyncServiceProvider = Provider<WalletSyncService>((ref) {
  final remote = ref.watch(walletRemoteDatasourceProvider);
  final authRemote = ref.watch(authRemoteDatasourceProvider);
  final userLocal = ref.watch(userLocalDatasourceProvider);
  final db = ref.watch(appDatabaseProvider);
  final logger = ref.watch(appLoggerProvider);
  final storage = ref.watch(secureStorageProvider);
  return WalletSyncService(remote, authRemote, userLocal, db, logger, storage);
});
