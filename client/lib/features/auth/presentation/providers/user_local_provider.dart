import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_service.dart';
import '../../data/datasources/user_local_datasource.dart';

final userLocalDatasourceProvider = Provider<UserLocalDatasource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return UserLocalDatasource(db);
});
