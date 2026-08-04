import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_service.dart';

final recentTransactionsProvider = StreamProvider<List<TransactionEntry>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchRecentTransactions();
});

final allTransactionsProvider = StreamProvider<List<TransactionEntry>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchAllTransactions();
});
