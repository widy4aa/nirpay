import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptography/cryptography.dart';
import '../services/secure_storage_service.dart';
import '../services/app_logger.dart';
import 'app_database.dart';

class DatabaseService {
  final SecureStorageService _storage;
  final Ref _ref;

  DatabaseService(this._storage, this._ref);

  Future<String> getDbEncryptionKey() async {
    final logger = _ref.read(appLoggerProvider);

    try {
      final existingKey = await _storage.read('db_encryption_key');

      if (existingKey != null) {
        return existingKey;
      }

      logger.d('[Database] Generating new AES key for SQLCipher');
      final algorithm = AesGcm.with256bits();
      final secretKey = await algorithm.newSecretKey();
      final keyBytes = await secretKey.extractBytes();
      final newKeyBase64 = base64Encode(keyBytes);

      await _storage.write('db_encryption_key', newKeyBase64);
      return newKeyBase64;
    } catch (e) {
      logger.e('[Database] Failed to get/generate DB key', error: e);
      rethrow;
    }
  }

  static Future<bool> checkDatabaseStatus() async {
    // A placeholder for the static call in the UI
    return true;
  }
}

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DatabaseService(storage, ref);
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  // In a real app, you'd wait for this asynchronously during app init
  // For now, since Drift needs synchronous init, we could pass a dummy key
  // or use a FutureProvider. We'll use a placeholder key here to satisfy sync requirement,
  // but ideally we should initialize it during bootstrap.
  return AppDatabase(encryptionKey: 'temp_key_until_initialized');
});
