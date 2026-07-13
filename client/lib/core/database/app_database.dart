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
  TextColumn get phone => text().nullable()();
  TextColumn get publicKeyB64 => text().named('public_key_b64').nullable()();
  TextColumn get pinHash => text().named('pin_hash').nullable()();
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
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA journal_mode=WAL');
      await customStatement('PRAGMA foreign_keys=ON');
    },
  );
}
