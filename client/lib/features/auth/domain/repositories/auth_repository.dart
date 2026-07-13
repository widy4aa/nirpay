import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String pin);

  Future<Either<Failure, bool>> checkAvailability(String email, String phone);

  Future<Either<Failure, String>> sendOtp(String email, String phone);

  Future<Either<Failure, bool>> verifyOtp(String otpId, String otpCode);

  Future<Either<Failure, bool>> checkUsername(String username);

  Future<Either<Failure, User>> register({
    required String email,
    required String phone,
    required String username,
    required String fullName,
    required String pin,
    required String publicKeyB64,
  });

  Future<Either<Failure, void>> logout();
}
