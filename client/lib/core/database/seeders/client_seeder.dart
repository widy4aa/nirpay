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

  // ─── Account 1: User1 ───
  static const _user1 = User(
    id: 'user1-0000-0000-0000-000000000001',
    email: 'user1@gmail.com',
    fullName: 'User Satu',
    username: 'user1',
    role: 'USER',
    phone: '081111111111',
    kycStatus: 'APPROVED',
    nik: '3201234567890001',
    province: 'DKI Jakarta',
    city: 'Jakarta Selatan',
    district: 'Kebayoran Baru',
    village: 'Gandaria Utara',
    postalCode: '12140',
    rt: '001',
    rw: '002',
    gender: 'MALE',
  );

  // ─── Account 2: User2 ───
  static const _user2 = User(
    id: 'user2-0000-0000-0000-000000000002',
    email: 'user2@gmail.com',
    fullName: 'User Dua',
    username: 'user2',
    role: 'USER',
    phone: '082222222222',
    kycStatus: 'APPROVED',
    nik: '3201234567890002',
    province: 'Jawa Barat',
    city: 'Bandung',
    district: 'Coblong',
    village: 'Dago',
    postalCode: '40135',
    rt: '003',
    rw: '005',
    gender: 'FEMALE',
  );

  // Saldo awal: Rp 100.000 (10000000 cent)
  static const _initialBalance = 10000000;

  /// Seed data dummy untuk development.
  /// TIDAK menyimpan token atau PIN hash — user WAJIB login via API.
  Future<void> seedDummyData() async {
    // ── 1. Seed Users (hanya jika belum ada) ──
    final existingUser = await _userLocal.getActiveUser();
    if (existingUser == null) {
      await _userLocal.saveUser(_user1);
      await _userLocal.saveUser(_user2);
    }

    // ── 2. Seed Wallet Balances (match backend) ──
    final existingBalance1 = await _db.getWalletBalance(_user1.id);
    if (existingBalance1 == null) {
      // User1: Rp 100.000
      await _db.upsertWalletBalance(
        WalletBalancesCompanion.insert(
          id: 'wallet-user1',
          userId: _user1.id,
          amountCent: const Value(_initialBalance),
          reservedCent: const Value(0),
          hopCount: const Value(0),
          maxHop: const Value(3),
          currency: const Value('IDR'),
        ),
      );
    }

    final existingBalance2 = await _db.getWalletBalance(_user2.id);
    if (existingBalance2 == null) {
      // User2: Rp 100.000
      await _db.upsertWalletBalance(
        WalletBalancesCompanion.insert(
          id: 'wallet-user2',
          userId: _user2.id,
          amountCent: const Value(_initialBalance),
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
      // User1: TOPUP Rp 100.000
      await _db.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-topup-user1',
          txId: 'tx-topup-user1',
          direction: 'CREDIT',
          txType: 'TOPUP',
          amountCent: _initialBalance,
          syncStatus: const Value('SYNCED'),
          createdAt: Value(DateTime.now().subtract(const Duration(days: 3))),
        ),
      );

      // User2: TOPUP Rp 100.000
      await _db.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-topup-user2',
          txId: 'tx-topup-user2',
          direction: 'CREDIT',
          txType: 'TOPUP',
          amountCent: _initialBalance,
          syncStatus: const Value('SYNCED'),
          createdAt: Value(DateTime.now().subtract(const Duration(days: 3))),
        ),
      );
    }

    // ── TIDAK menyimpan token atau PIN hash ──
    // User WAJIB login via API untuk mendapatkan JWT token
  }
}

final clientSeederProvider = Provider<ClientSeeder>((ref) {
  final userLocal = ref.watch(userLocalDatasourceProvider);
  final storage = ref.watch(secureStorageProvider);
  final db = ref.watch(appDatabaseProvider);
  return ClientSeeder(userLocal, storage, db);
});
