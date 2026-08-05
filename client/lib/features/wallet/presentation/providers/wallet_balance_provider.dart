import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/database/app_database.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Stream wallet balance milik user yang sedang aktif
final walletBalanceProvider = StreamProvider<WalletBalanceEntry?>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) {
    return const Stream.empty();
  }

  return (db.select(db.walletBalances)
        ..where((w) => w.userId.equals(currentUser.id))
        ..limit(1))
      .watchSingleOrNull();
});
