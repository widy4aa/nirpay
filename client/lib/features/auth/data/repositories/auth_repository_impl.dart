import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final Logger _logger;

  AuthRepositoryImpl(this._remoteDatasource, this._logger);

  @override
  Future<Either<Failure, User>> register(RegisterParams params) async {
    try {
      _logger.d('[Auth] Registering user: ${params.email}');
      final data = await _remoteDatasource.register(params.toJson());
      // The register endpoint might not return the full user, just userId and tokens.
      // Assuming it returns userId, we can just create a User from params.
      final user = User(
        id: data['userId'],
        email: params.email,
        fullName: params.fullName,
        username: params.username,
        role: 'USER',
      );
      return Right(user);
    } on DioException catch (e) {
      _logger.e('[Auth] Register failed', error: e, stackTrace: e.stackTrace);
      return Left(
        ServerFailure(
          message:
              e.response?.data?['message'] ?? e.message ?? 'Register failed',
          code: e.response?.statusCode?.toString(),
        ),
      );
    } catch (e) {
      _logger.e('[Auth] Register cache/parsing error', error: e);
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> login(
    String email,
    String password,
  ) async {
    try {
      _logger.d('[Auth] Logging in: $email');
      final data = await _remoteDatasource.login(email, password);
      final userModel = UserModel.fromJson(data.user);
      final tokens = AuthTokens(
        accessToken: data.tokens['accessToken'],
        refreshToken: data.tokens['refreshToken'],
        user: userModel.toEntity(),
      );
      return Right(tokens);
    } on DioException catch (e) {
      _logger.e('[Auth] Login failed', error: e, stackTrace: e.stackTrace);
      return Left(
        ServerFailure(
          message: e.response?.data?['message'] ?? e.message ?? 'Login failed',
          code: e.response?.statusCode?.toString(),
        ),
      );
    } catch (e) {
      _logger.e('[Auth] Login cache/parsing error', error: e);
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> verifyPin(
    String pin,
    String refreshToken,
  ) async {
    try {
      _logger.d('[Auth] Verifying PIN');
      final data = await _remoteDatasource.verifyPin(pin, refreshToken);
      return Right(
        AuthTokens(
          accessToken: data.accessToken,
          refreshToken: data.refreshToken,
          user: UserModel.fromJson(data.user).toEntity(),
        ),
      );
    } on DioException catch (e) {
      _logger.e('[Auth] Verify PIN failed', error: e, stackTrace: e.stackTrace);
      return Left(
        ServerFailure(
          message:
              e.response?.data?['message'] ?? e.message ?? 'Verify PIN failed',
          code: e.response?.statusCode?.toString(),
        ),
      );
    } catch (e) {
      _logger.e('[Auth] Verify PIN error', error: e);
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> sendOtp(
    String email,
    String phone,
    String type,
  ) async {
    try {
      _logger.d('[Auth] Sending OTP to $email');
      final data = await _remoteDatasource.sendOtp(email, phone, type);
      return Right(data);
    } on DioException catch (e) {
      _logger.e('[Auth] Send OTP failed', error: e, stackTrace: e.stackTrace);
      return Left(
        ServerFailure(
          message:
              e.response?.data?['message'] ?? e.message ?? 'Send OTP failed',
          code: e.response?.statusCode?.toString(),
        ),
      );
    } catch (e) {
      _logger.e('[Auth] Send OTP error', error: e);
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtp(String otpId, String otpCode) async {
    try {
      _logger.d('[Auth] Verifying OTP: $otpId');
      final data = await _remoteDatasource.verifyOtp(otpId, otpCode);
      return Right(data['verified'] == true);
    } on DioException catch (e) {
      _logger.e('[Auth] Verify OTP failed', error: e, stackTrace: e.stackTrace);
      return Left(
        ServerFailure(
          message:
              e.response?.data?['message'] ?? e.message ?? 'Verify OTP failed',
          code: e.response?.statusCode?.toString(),
        ),
      );
    } catch (e) {
      _logger.e('[Auth] Verify OTP error', error: e);
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkAvailability(
    String email,
    String phone,
  ) async {
    try {
      _logger.d('[Auth] Checking availability for $email');
      final data = await _remoteDatasource.checkAvailability(email, phone);
      return Right(
        data['emailAvailable'] == true && data['phoneAvailable'] == true,
      );
    } on DioException catch (e) {
      _logger.e(
        '[Auth] Check availability failed',
        error: e,
        stackTrace: e.stackTrace,
      );
      return Left(
        ServerFailure(
          message:
              e.response?.data?['message'] ??
              e.message ??
              'Check availability failed',
          code: e.response?.statusCode?.toString(),
        ),
      );
    } catch (e) {
      _logger.e('[Auth] Check availability error', error: e);
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkUsername(String username) async {
    try {
      _logger.d('[Auth] Checking username: $username');
      final data = await _remoteDatasource.checkUsername(username);
      return Right(data['available'] == true);
    } on DioException catch (e) {
      _logger.e(
        '[Auth] Check username failed',
        error: e,
        stackTrace: e.stackTrace,
      );
      return Left(
        ServerFailure(
          message:
              e.response?.data?['message'] ??
              e.message ??
              'Check username failed',
          code: e.response?.statusCode?.toString(),
        ),
      );
    } catch (e) {
      _logger.e('[Auth] Check username error', error: e);
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
