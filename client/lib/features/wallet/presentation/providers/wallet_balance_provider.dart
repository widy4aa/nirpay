import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/database/app_database.dart';

final walletBalanceProvider = StreamProvider<WalletBalanceEntry?>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.walletBalances).watchSingleOrNull();
});
