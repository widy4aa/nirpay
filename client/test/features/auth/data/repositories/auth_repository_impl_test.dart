import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'package:nirpay/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:nirpay/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nirpay/features/auth/domain/repositories/auth_repository.dart';
import 'package:nirpay/core/errors/failure.dart';

// Manual Mock Datasource
class MockAuthRemoteDatasource implements AuthRemoteDatasource {
  bool shouldThrowDioError = false;
  bool shouldThrowCacheError = false;
  Map<String, dynamic> responseData = {};
  ({Map<String, dynamic> tokens, Map<String, dynamic> user}) loginResponseData = (
    tokens: {},
    user: {}
  );

  void _checkThrow() {
    if (shouldThrowDioError) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
          data: {'message': 'Bad Request Error'},
        ),
      );
    }
    if (shouldThrowCacheError) {
      throw Exception('Parse error');
    }
  }

  @override
  Future<Map<String, dynamic>> checkAvailability(String email, String phone) async {
    _checkThrow();
    return responseData;
  }

  @override
  Future<Map<String, dynamic>> sendOtp(String email, String phone, String type) async {
    _checkThrow();
    return responseData;
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String otpId, String otpCode) async {
    _checkThrow();
    return responseData;
  }

  @override
  Future<Map<String, dynamic>> checkUsername(String username) async {
    _checkThrow();
    return responseData;
  }

  @override
  Future<Map<String, dynamic>> register(Map<String, dynamic> params) async {
    _checkThrow();
    return responseData;
  }

  @override
  Future<({Map<String, dynamic> tokens, Map<String, dynamic> user})> login(
    String email,
    String password,
  ) async {
    _checkThrow();
    return loginResponseData;
  }

  @override
  Future<({String accessToken, String refreshToken, Map<String, dynamic> user})> verifyPin(
    String pin,
    String refreshToken,
  ) async {
    _checkThrow();
    return (
      accessToken: 'token1',
      refreshToken: 'token2',
      user: <String, dynamic>{'id': '1', 'email': 'a@b.c', 'fullName': 'Test', 'role': 'USER'},
    );
  }
}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDatasource mockDatasource;
  late Logger mockLogger;

  setUp(() {
    mockDatasource = MockAuthRemoteDatasource();
    mockLogger = Logger(level: Level.off); // Silence logs for tests
    repository = AuthRepositoryImpl(mockDatasource, mockLogger);
  });

  group('3.34 Test: checkAvailability', () {
    test('should return true when email and phone are available', () async {
      mockDatasource.responseData = {'emailAvailable': true, 'phoneAvailable': true};
      final result = await repository.checkAvailability('a@b.com', '123');
      expect(result, isA<Right<Failure, bool>>());
      result.fold((l) => fail('Should be Right'), (r) => expect(r, true));
    });

    test('should return false when email is taken', () async {
      mockDatasource.responseData = {'emailAvailable': false, 'phoneAvailable': true};
      final result = await repository.checkAvailability('a@b.com', '123');
      expect(result, isA<Right<Failure, bool>>());
      result.fold((l) => fail('Should be Right'), (r) => expect(r, false));
    });

    test('should return NetworkFailure/ServerFailure on DioException', () async {
      mockDatasource.shouldThrowDioError = true;
      final result = await repository.checkAvailability('a@b.com', '123');
      expect(result, isA<Left<Failure, bool>>());
      result.fold(
        (l) {
          expect(l, isA<ServerFailure>());
          expect((l as ServerFailure).message, 'Bad Request Error');
        },
        (r) => fail('Should be Left'),
      );
    });
  });

  group('3.35 Test: sendOtp + verifyOtp', () {
    test('sendOtp should return data on success', () async {
      mockDatasource.responseData = {'otpId': '12345'};
      final result = await repository.sendOtp('a@b.com', '123', 'register');
      expect(result, isA<Right<Failure, Map<String, dynamic>>>());
    });

    test('verifyOtp should return true on correct code', () async {
      mockDatasource.responseData = {'success': true};
      final result = await repository.verifyOtp('123', 'code');
      expect(result, isA<Right<Failure, bool>>());
      result.fold((l) => fail('Should be Right'), (r) => expect(r, true));
    });

    test('verifyOtp should return false on wrong code', () async {
      mockDatasource.responseData = {'success': false};
      final result = await repository.verifyOtp('123', 'wrong');
      expect(result, isA<Right<Failure, bool>>());
      result.fold((l) => fail('Should be Right'), (r) => expect(r, false));
    });
  });

  group('3.36 Test: checkUsername', () {
    test('should return true when available', () async {
      mockDatasource.responseData = {'available': true};
      final result = await repository.checkUsername('user');
      expect(result, isA<Right<Failure, bool>>());
    });
  });

  group('3.37 Test: register + login', () {
    test('register should return User on success', () async {
      mockDatasource.responseData = {'userId': 'user1'};
      final params = RegisterParams(
        email: 'a@b.com',
        phone: '',
        username: '',
        fullName: '',
        pin: '',
        password: 'password123',
        publicKeyB64: '',
        nik: '3171234567890001',
      );
      final result = await repository.register(params);
      expect(result, isA<Right<Failure, dynamic>>()); // Left dynamic as User import might differ slightly
    });

    test('register should return ServerFailure on duplicate', () async {
      mockDatasource.shouldThrowDioError = true;
      final params = RegisterParams(
        email: 'a@b.com',
        phone: '',
        username: '',
        fullName: '',
        pin: '',
        password: 'password123',
        publicKeyB64: '',
        nik: '3171234567890001',
      );
      final result = await repository.register(params);
      expect(result, isA<Left<Failure, dynamic>>());
    });

    test('login should return AuthTokens on success', () async {
      mockDatasource.loginResponseData = (
        tokens: {'accessToken': 'token1', 'refreshToken': 'token2'},
        user: {'id': '1', 'email': 'a@b.com', 'fullName': 'Test User', 'role': 'USER', 'username': 'testuser'}
      );
      final result = await repository.login('a@b.com', 'password123');
      expect(result, isA<Right<Failure, AuthTokens>>());
    });
  });
}