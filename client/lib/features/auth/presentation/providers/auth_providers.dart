import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/upload_service.dart';
import '../../../../core/services/app_logger.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';

final uploadServiceProvider = Provider<UploadService>((ref) {
  final dio = ref.read(dioProvider);
  return UploadService(dio);
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDatasource(dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDatasource = ref.watch(authRemoteDatasourceProvider);
  final logger = ref.watch(appLoggerProvider);
  return AuthRepositoryImpl(remoteDatasource, logger);
});

// Current user provider - stores the logged in user
final currentUserProvider = StateProvider<User?>((ref) => null);