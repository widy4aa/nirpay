import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:drift/drift.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/app_logger.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletSyncService {
  final WalletRemoteDatasource _remoteDatasource;
  final AppDatabase _db;
  final Logger _logger;

  WalletSyncService(this._remoteDatasource, this._db, this._logger);

  Future<void> syncBalance() async {
    try {
      _logger.d('[Wallet] Syncing balance from server');
      final data = await _remoteDatasource.getBalance();
      
      await _db.into(_db.walletBalances).insertOnConflictUpdate(
        WalletBalancesCompanion(
          id: Value(data['id'] ?? 'primary'), // Ensure there's an ID
          userId: Value(data['userId'] ?? ''), // Needs actual user ID mapping
          amountCent: Value(int.parse(data['amountCent'] ?? '0')),
          reservedCent: Value(int.parse(data['reservedCent'] ?? '0')),
          currency: Value(data['currency'] ?? 'IDR'),
        ),
      );
      _logger.d('[Wallet] Balance synced successfully');
    } catch (e) {
      _logger.e('[Wallet] Sync balance failed', error: e);
    }
  }
}

final walletRemoteDatasourceProvider = Provider<WalletRemoteDatasource>((ref) {
  return WalletRemoteDatasource(ref.watch(dioProvider));
});

final walletSyncServiceProvider = Provider<WalletSyncService>((ref) {
  final remote = ref.watch(walletRemoteDatasourceProvider);
  final db = ref.watch(appDatabaseProvider);
  final logger = ref.watch(appLoggerProvider);
  return WalletSyncService(remote, db, logger);
});
