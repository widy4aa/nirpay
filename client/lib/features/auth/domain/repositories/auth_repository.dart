import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user.dart';

class RegisterParams {
  final String email;
  final String phone;
  final String username;
  final String fullName;
  final String pin;
  final String publicKeyB64;

  RegisterParams({
    required this.email,
    required this.phone,
    required this.username,
    required this.fullName,
    required this.pin,
    required this.publicKeyB64,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'phone': phone,
    'username': username,
    'fullName': fullName,
    'pin': pin,
    'publicKeyB64': publicKeyB64,
  };
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}

abstract class AuthRepository {
  Future<Either<Failure, User>> register(RegisterParams params);
  Future<Either<Failure, AuthTokens>> login(String email, String pin);
  Future<Either<Failure, Map<String, dynamic>>> sendOtp(
    String email,
    String phone,
    String type,
  );
  Future<Either<Failure, bool>> verifyOtp(String otpId, String otpCode);
  Future<Either<Failure, bool>> checkAvailability(String email, String phone);
  Future<Either<Failure, bool>> checkUsername(String username);
}
