import 'package:drift/drift.dart';

// Assuming we use drift_flutter later or sqlite3 directly.
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

@DataClassName('UserEntry')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get username => text()();
  TextColumn get fullName => text().named('full_name').withDefault(const Constant(''))();
  TextColumn get phone => text().nullable()();
  TextColumn get role => text().withDefault(const Constant('USER'))();
  TextColumn get kycStatus => text().named('kyc_status').nullable()();
  TextColumn get nik => text().nullable()();
  TextColumn get province => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get district => text().nullable()();
  TextColumn get village => text().nullable()();
  TextColumn get postalCode => text().named('postal_code').nullable()();
  TextColumn get rt => text().nullable()();
  TextColumn get rw => text().nullable()();
  TextColumn get ktpPhotoUrl => text().named('ktp_photo_url').nullable()();
  TextColumn get profilePhotoUrl => text().named('profile_photo_url').nullable()();
  TextColumn get kycFaceUrl => text().named('kyc_face_url').nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get publicKeyB64 => text().named('public_key_b64').nullable()();
  BoolColumn get isDirty => boolean().named('is_dirty').withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WalletBalanceEntry')
class WalletBalances extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  IntColumn get amountCent =>
      integer().named('amount_cent').withDefault(const Constant(0))();
  IntColumn get reservedCent =>
      integer().named('reserved_cent').withDefault(const Constant(0))();
  IntColumn get hopCount =>
      integer().named('hop_count').withDefault(const Constant(0))();
  IntColumn get maxHop =>
      integer().named('max_hop').withDefault(const Constant(3))();
  TextColumn get currency => text().withDefault(const Constant('IDR'))();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TransactionEntry')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get txId => text().named('tx_id')();
  TextColumn get direction => text().withLength(min: 1, max: 7)();
  TextColumn get txType => text().named('tx_type')();
  IntColumn get amountCent => integer().named('amount_cent')();
  IntColumn get hopCount =>
      integer().named('hop_count').withDefault(const Constant(0))();
  TextColumn get syncStatus =>
      text().named('sync_status').withDefault(const Constant('PENDING'))();
  TextColumn get counterpartyName =>
      text().named('counterparty_name').nullable()();
  TextColumn get counterpartyId =>
      text().named('counterparty_id').nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [Users, WalletBalances, Transactions])
class AppDatabase extends _$AppDatabase {
  final String encryptionKey;

  AppDatabase({required this.encryptionKey}) : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Tambah kolom baru di Users table
        await m.addColumn(users, users.fullName);
        await m.addColumn(users, users.role);
        await m.addColumn(users, users.kycStatus);
        await m.addColumn(users, users.nik);
        await m.addColumn(users, users.province);
        await m.addColumn(users, users.city);
        await m.addColumn(users, users.district);
        await m.addColumn(users, users.village);
        await m.addColumn(users, users.postalCode);
        await m.addColumn(users, users.rt);
        await m.addColumn(users, users.rw);
        await m.addColumn(users, users.ktpPhotoUrl);
        await m.addColumn(users, users.kycFaceUrl);
        await m.addColumn(users, users.gender);
      }
      if (from < 3) {
        // Tambah kolom counterparty di Transactions table
        await m.addColumn(transactions, transactions.counterpartyName);
        await m.addColumn(transactions, transactions.counterpartyId);
      }
      if (from < 4) {
        // Tambah kolom isDirty di Users table
        await m.addColumn(users, users.isDirty);
      }
      if (from < 5) {
        // Tambah kolom profilePhotoUrl di Users table
        await m.addColumn(users, users.profilePhotoUrl);
      }
    },
    beforeOpen: (details) async {
      await customStatement("PRAGMA key = '$encryptionKey'");
      await customStatement('PRAGMA journal_mode=WAL');
      await customStatement('PRAGMA foreign_keys=ON');
    },
  );

  // === User Operations ===

  Future<void> upsertUser(UsersCompanion user) async {
    await into(users).insertOnConflictUpdate(user);
  }

  Future<UserEntry?> getUserById(String userId) async {
    return (select(users)..where((u) => u.id.equals(userId))).getSingleOrNull();
  }

  Future<UserEntry?> getActiveUser() async {
    return (select(users)..limit(1)).getSingleOrNull();
  }

  /// Update user fields dan tandai isDirty = true
  Future<void> updateUserDirty(String userId, UsersCompanion data) async {
    await (update(users)..where((u) => u.id.equals(userId))).write(
      data.copyWith(isDirty: const Value(true)),
    );
  }

  /// Ambil semua user yang isDirty = true
  Future<List<UserEntry>> getDirtyUsers() async {
    return (select(users)..where((u) => u.isDirty.equals(true))).get();
  }

  /// Tandai user sebagai clean (sudah di-sync)
  Future<void> markUserClean(String userId) async {
    await (update(users)..where((u) => u.id.equals(userId))).write(
      const UsersCompanion(isDirty: Value(false)),
    );
  }

  // === Wallet Balance Operations ===

  Future<void> upsertWalletBalance(WalletBalancesCompanion balance) async {
    await into(walletBalances).insertOnConflictUpdate(balance);
  }

  Future<WalletBalanceEntry?> getWalletBalance(String userId) async {
    return (select(walletBalances)..where((w) => w.userId.equals(userId))..limit(1))
        .getSingleOrNull();
  }

  /// Increment hop count setelah transfer offline berhasil (sender)
  Future<void> incrementHopCount(String userId) async {
    final balance = await getWalletBalance(userId);
    if (balance != null) {
      await (update(walletBalances)..where((w) => w.userId.equals(userId))).write(
        WalletBalancesCompanion(
          hopCount: Value(balance.hopCount + 1),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  /// Reset hop count ke 0 setelah sync ke server berhasil
  Future<void> resetHopCount(String userId) async {
    await (update(walletBalances)..where((w) => w.userId.equals(userId))).write(
      WalletBalancesCompanion(
        hopCount: const Value(0),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // === Transaction Operations ===

  Future<void> insertTransaction(TransactionsCompanion tx) async {
    await into(transactions).insertOnConflictUpdate(tx);
  }

  Future<int> getTransactionCount() async {
    final countExp = transactions.id.count();
    final query = selectOnly(transactions)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  Stream<List<TransactionEntry>> watchRecentTransactions() {
    return (select(transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(5))
        .watch();
  }

  Stream<List<TransactionEntry>> watchAllTransactions() {
    return (select(transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }
}
