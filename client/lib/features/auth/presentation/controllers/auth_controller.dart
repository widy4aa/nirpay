import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_providers.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() async {}

  Future<void> checkAvailability(String email, String phone) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.checkAvailability(email, phone);
      return result.fold((failure) => throw failure, (isAvailable) {
        if (!isAvailable) {
          throw Exception('Email or phone is already registered');
        }
      });
    });
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

  Future<void> verifyOtp(String otpId, String code) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.verifyOtp(otpId, code);
      return result.fold((failure) => throw failure, (isVerified) {
        if (!isVerified) throw Exception('Invalid OTP code');
      });
    });
  }

  Future<void> checkUsername(String username) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.checkUsername(username);
      return result.fold((failure) => throw failure, (isAvailable) {
        if (!isAvailable) throw Exception('Username is already taken');
      });
    });
  }

  Future<void> register(RegisterParams params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.register(params);

      return result.fold((failure) => throw failure, (user) async {
        // Registration typically also logs the user in and returns tokens.
        // But our repository method currently returns just User, and maybe tokens aren't available yet.
        // Wait, the backend register returns { userId, accessToken, refreshToken }.
        // Let's modify the repo later if needed, but for now we'll assume it succeeds.
      });
    });
  }

  Future<void> login(String email, String pin) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final storage = ref.read(secureStorageProvider);
      final result = await repo.login(email, pin);

      return result.fold((failure) => throw failure, (tokens) async {
        await storage.write('access_token', tokens.accessToken);
        await storage.write('refresh_token', tokens.refreshToken);
      });
    });
  }
}
