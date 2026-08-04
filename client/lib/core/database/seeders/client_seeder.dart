import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/domain/entities/user.dart';
import '../../../features/auth/data/datasources/user_local_datasource.dart';
import '../../../features/auth/presentation/providers/user_local_provider.dart';
import '../../services/secure_storage_service.dart';
import '../database_service.dart';
import '../app_database.dart';

class ClientSeeder {
  final UserLocalDatasource _userLocal;
  final SecureStorageService _storage;
  final AppDatabase _db;

  ClientSeeder(this._userLocal, this._storage, this._db);

  // ─── Account 1: Dio ───
  static const _user1 = User(
    id: '008357ea-83ac-45ee-85f8-7e4d49a15440',
    email: 'dio34678@gmail.com',
    fullName: 'Dio Pratama',
    username: 'dio34678',
    role: 'USER',
    phone: '081234567893',
    kycStatus: 'APPROVED',
    nik: '3201234567890004',
    province: 'DKI Jakarta',
    city: 'Jakarta Selatan',
    district: 'Kebayoran Baru',
    village: 'Gandaria Utara',
    postalCode: '12140',
    rt: '003',
    rw: '005',
    gender: 'MALE',
  );

  // ─── Account 2: Drivedio ───
  static const _user2 = User(
    id: '6f459645-398c-41ee-a6fb-51c691e4f5e1',
    email: 'drivedio34@gmail.com',
    fullName: 'Drive Dio',
    username: 'drivedio34',
    role: 'USER',
    phone: '081234567894',
    kycStatus: 'APPROVED',
    nik: '3201234567890005',
    province: 'DKI Jakarta',
    city: 'Jakarta Timur',
    district: 'Cakung',
    village: 'Penggilingan',
    postalCode: '13940',
    rt: '001',
    rw: '002',
    gender: 'MALE',
  );

  // Saldo awal dari transaksi TOPUP (konsisten dengan backend)
  static const _topupAmount = 5000000; // Rp 50.000 (50000 cent)

  /// Seed 2 dummy accounts + wallet balances + transactions
  Future<void> seedDummyUser() async {
    // ── 1. Seed Users ──
    final existingUser = await _userLocal.getActiveUser();
    if (existingUser == null) {
      await _userLocal.saveUser(_user1);
      await _userLocal.saveUser(_user2);
      // Token TIDAK di-set — user harus login via API untuk dapat JWT asli
    }

    // PIN: 123123 (6 digit) — bcrypt hash
    // Password untuk login online: 12312312
    await _storage.write(
      'saved_pin_hash',
      r'$2b$12$LhCnt25NDJItt28NqrRjpea2H5iDJs3ViOzPxk2kmxahuZ3zOUGm6',
    );

    // ── 2. Seed Wallet Balances (dari transaksi TOPUP, konsisten dengan backend) ──
    final existingBalance = await _db.getWalletBalance(_user1.id);
    if (existingBalance == null) {
      // Dio: Rp 50.000 (dari TOPUP)
      await _db.upsertWalletBalance(
        WalletBalancesCompanion.insert(
          id: 'wallet-dio',
          userId: _user1.id,
          amountCent: const Value(_topupAmount),
          reservedCent: const Value(0),
          hopCount: const Value(0),
          maxHop: const Value(3),
          currency: const Value('IDR'),
        ),
      );

      // Drivedio: Rp 50.000 (dari TOPUP)
      await _db.upsertWalletBalance(
        WalletBalancesCompanion.insert(
          id: 'wallet-drivedio',
          userId: _user2.id,
          amountCent: const Value(_topupAmount),
          reservedCent: const Value(0),
          hopCount: const Value(0),
          maxHop: const Value(3),
          currency: const Value('IDR'),
        ),
      );
    }

    // ── 3. Seed Transactions (TOPUP awal) ──
    final txCount = await _db.getTransactionCount();
    if (txCount == 0) {
      // Dio: TOPUP Rp 50.000
      await _db.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-topup-dio',
          txId: 'tx-topup-dio',
          direction: 'CREDIT',
          txType: 'TOPUP',
          amountCent: _topupAmount,
          syncStatus: const Value('SYNCED'),
          createdAt: Value(DateTime.now().subtract(const Duration(days: 3))),
        ),
      );

      // Drivedio: TOPUP Rp 50.000
      await _db.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-topup-drivedio',
          txId: 'tx-topup-drivedio',
          direction: 'CREDIT',
          txType: 'TOPUP',
          amountCent: _topupAmount,
          syncStatus: const Value('SYNCED'),
          createdAt: Value(DateTime.now().subtract(const Duration(days: 3))),
        ),
      );
    }
  }
}

final clientSeederProvider = Provider<ClientSeeder>((ref) {
  final userLocal = ref.watch(userLocalDatasourceProvider);
  final storage = ref.watch(secureStorageProvider);
  final db = ref.watch(appDatabaseProvider);
  return ClientSeeder(userLocal, storage, db);
});
