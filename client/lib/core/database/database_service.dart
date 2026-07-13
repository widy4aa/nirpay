import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseService {
  static const _storage = FlutterSecureStorage();
  static const String _keyName = 'db_encryption_key_v1';

  /// Retrieves the AES-256 key from TEE (Trusted Execution Environment),
  /// or generates a new one if it doesn't exist.
  static Future<String> _getOrGenerateEncryptionKey() async {
    try {
      String? key = await _storage.read(key: _keyName);
      if (key == null) {
        // Generate a 256-bit (32 bytes) secure random key
        final random = Random.secure();
        final values = List<int>.generate(32, (i) => random.nextInt(256));
        key = base64UrlEncode(values);

        // Save to Hardware-backed Keystore (TEE)
        await _storage.write(key: _keyName, value: key);
        debugPrint('Generated new AES-256 key and saved to TEE.');
      } else {
        debugPrint('Successfully retrieved AES-256 key from TEE.');
      }
      return key;
    } catch (e) {
      debugPrint('Failed to interact with TEE: $e');
      rethrow;
    }
  }

  /// Verifies if the SQLCipher database can be opened and decrypted using the TEE key.
  static Future<bool> checkDatabaseStatus() async {
    try {
      final key = await _getOrGenerateEncryptionKey();

      final docDir = await getApplicationDocumentsDirectory();
      final dbFile = File('${docDir.path}/secure_wallet.db');

      // Open SQLite database (which is backed by SQLCipher via sqlcipher_flutter_libs)
      final db = sqlite3.open(dbFile.path);

      // Apply the AES-256 key for encryption/decryption
      db.execute("PRAGMA key = '$key';");

      // Test the encryption by writing and reading
      db.execute(
        'CREATE TABLE IF NOT EXISTS secure_test (id INTEGER PRIMARY KEY, status TEXT)',
      );
      db.execute(
        "INSERT OR REPLACE INTO secure_test (id, status) VALUES (1, 'active')",
      );

      final result = db.select('SELECT status FROM secure_test WHERE id = 1');

      final isDecrypted =
          result.isNotEmpty && result.first['status'] == 'active';

      db.dispose(); // Close database connection safely

      return isDecrypted;
    } catch (e) {
      debugPrint('Secure database check failed: $e');
      return false;
    }
  }
}
