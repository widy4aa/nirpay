import 'package:bcrypt/bcrypt.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/providers/app_providers.dart';

import '../../../../core/database/database_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_providers.dart';
import '../providers/user_local_provider.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() async {
    await _restoreUserFromDb();
  }

  Future<void> _restoreUserFromDb() async {
    try {
      final userLocal = ref.read(userLocalDatasourceProvider);
      final user = await userLocal.getActiveUser();
      if (user != null) {
        ref.read(currentUserProvider.notifier).state = user;
      }
    } catch (_) {}
  }

  Future<bool> checkAvailability(String email, String phone) async {
    state = const AsyncLoading();
    bool success = false;
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.checkAvailability(email, phone);
      return result.fold((failure) => throw failure, (isAvailable) {
        if (!isAvailable) {
          throw Exception('Email or phone is already registered');
        }
        success = true;
      });
    });
    return success;
  }

  Future<String> sendOtp(String email, String phone) async {
    state = const AsyncLoading();
    String otpId = '';
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.sendOtp(email, phone, 'register');
      return result.fold((failure) => throw failure, (data) {
        otpId = data['otpId'];
      });
    });
    return otpId;
  }

  Future<bool> verifyOtp(String otpId, String code) async {
    state = const AsyncLoading();
    bool success = false;
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.verifyOtp(otpId, code);
      return result.fold((failure) => throw failure, (isVerified) {
        if (!isVerified) throw Exception('Invalid OTP code');
        success = true;
      });
    });
    return success;
  }

  Future<bool> checkUsername(String username) async {
    state = const AsyncLoading();
    bool success = false;
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.checkUsername(username);
      return result.fold((failure) => throw failure, (isAvailable) {
        if (!isAvailable) throw Exception('Username is already taken');
        success = true;
      });
    });
    return success;
  }

  Future<void> register(RegisterParams params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.register(params);
      return result.fold((failure) => throw failure, (user) async {
        ref.read(currentUserProvider.notifier).state = user;
      });
    });
  }

  /// Login online — email + password saja, PIN tidak perlu
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final storage = ref.read(secureStorageProvider);
      final userLocal = ref.read(userLocalDatasourceProvider);
      final result = await repo.login(email, password);

      await result.fold(
        (failure) => throw failure,
        (tokens) async {
          // Simpan token di secure storage
          await storage.write('access_token', tokens.accessToken);
          await storage.write('refresh_token', tokens.refreshToken);

          // DEBUG: Log token yang tersimpan
          print('🔑 [DEBUG] access_token saved: ${tokens.accessToken.substring(0, 20)}...');
          print('🔑 [DEBUG] refresh_token saved: ${tokens.refreshToken.substring(0, 20)}...');

          // Simpan pinHash untuk verifikasi PIN lokal
          // PHP bcrypt pakai $2y$, Dart bcrypt pakai $2b$ — convert
          if (tokens.user.pinHash != null) {
            final hash = tokens.user.pinHash!.replaceAll(r'$2y$', r'$2b$');
            await storage.write('saved_pin_hash', hash);
          }

          // Simpan user data lengkap ke local database
          await userLocal.saveUser(tokens.user);

          ref.read(currentUserProvider.notifier).state = tokens.user;
        },
      );

      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow; // ← Penting! Supaya login page bisa catch
    }
  }

  /// PIN verifikasi — lokal dengan bcrypt, lalu coba refresh token jika ada internet
  Future<void> verifyPin(String pin) async {
    state = const AsyncLoading();
    try {
      final storage = ref.read(secureStorageProvider);
      final userLocal = ref.read(userLocalDatasourceProvider);

      // Ambil pinHash dari local storage
      final pinHash = await storage.read('saved_pin_hash');
      if (pinHash == null) {
        throw Exception('PIN belum tersimpan. Login ulang dengan internet.');
      }

      // Verifikasi PIN dengan bcrypt lokal
      final isValid = BCrypt.checkpw(pin, pinHash);
      if (!isValid) {
        throw Exception('PIN salah');
      }

      // Load user dari local database
      final user = await userLocal.getActiveUser();
      if (user == null) {
        throw Exception('Data user tidak ditemukan. Login ulang dengan internet.');
      }

      // Cek apakah sudah ada token asli (dari login API sebelumnya)
      final existingToken = await storage.read('access_token');
      final existingRefresh = await storage.read('refresh_token');
      final hasRealToken = existingToken != null &&
          existingToken != 'offline_token' &&
          existingToken != 'seeded_token';

      if (hasRealToken) {
        // Sudah punya token asli — biarkan, interceptor akan handle jika expired
        print('🔑 [Auth] PIN OK — keeping existing real token');
      } else if (existingRefresh != null &&
          existingRefresh != 'offline_refresh_token' &&
          existingRefresh != 'seeded_refresh_token') {
        // Ada refresh token asli — coba refresh untuk dapat access token baru
        print('🔑 [Auth] PIN OK — attempting token refresh...');
        try {
          final refreshDio = Dio(BaseOptions(
            baseUrl: ref.read(appConfigProvider).apiBaseUrl,
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          ));
          final response = await refreshDio.post(
            '/auth/refresh',
            options: Options(headers: {'Authorization': 'Bearer $existingRefresh'}),
          );
          final data = response.data['data'];
          await storage.write('access_token', data['accessToken']);
          await storage.write('refresh_token', data['refreshToken']);
          print('🔑 [Auth] Token refreshed successfully');
        } catch (e) {
          print('🔑 [Auth] Refresh failed, falling back to offline: $e');
          await storage.write('access_token', 'offline_token');
          await storage.write('refresh_token', 'offline_refresh_token');
        }
      } else {
        // Tidak ada token asli — offline mode
        print('🔑 [Auth] PIN OK — no real token, offline mode');
        await storage.write('access_token', 'offline_token');
        await storage.write('refresh_token', 'offline_refresh_token');
      }

      ref.read(currentUserProvider.notifier).state = user;
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Verifikasi PIN lokal murni (hanya return true/false, tanpa merubah session)
  Future<bool> checkPinLocal(String pin) async {
    try {
      final storage = ref.read(secureStorageProvider);
      final pinHash = await storage.read('saved_pin_hash');
      if (pinHash == null) return false;

      return BCrypt.checkpw(pin, pinHash);
    } catch (_) {
      return false;
    }
  }

  /// Logout — hapus SEMUA data lokal, harus login ulang dengan internet
  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);

    // Hapus semua data di secure storage (token, PIN, dll)
    await storage.deleteAll();

    // Hapus user dari local database
    final db = ref.read(appDatabaseProvider);
    await db.delete(db.users).go();

    // Reset state
    ref.read(currentUserProvider.notifier).state = null;
  }
}
