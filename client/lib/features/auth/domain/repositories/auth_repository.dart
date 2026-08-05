import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user.dart';

class RegisterParams {
  final String email;
  final String phone;
  final String username;
  final String fullName;
  final String pin;
  final String password;
  final String publicKeyB64;
  final String nik;
  final String? province;
  final String? city;
  final String? district;
  final String? village;
  final String? postalCode;
  final String? rt;
  final String? rw;
  final String? ktpPhotoUrl;
  final String? kycFaceUrl;
  final String? gender;
  final String? birthDate;

  RegisterParams({
    required this.email,
    required this.phone,
    required this.username,
    required this.fullName,
    required this.pin,
    required this.password,
    required this.publicKeyB64,
    required this.nik,
    this.province,
    this.city,
    this.district,
    this.village,
    this.postalCode,
    this.rt,
    this.rw,
    this.ktpPhotoUrl,
    this.kycFaceUrl,
    this.gender,
    this.birthDate,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'phone': phone,
        'username': username,
        'fullName': fullName,
        'pin': pin,
        'password': password,
        'publicKeyB64': publicKeyB64,
        'nik': nik,
        if (province != null) 'province': province,
        if (city != null) 'city': city,
        if (district != null) 'district': district,
        if (village != null) 'village': village,
        if (postalCode != null) 'postalCode': postalCode,
        if (rt != null) 'rt': rt,
        if (rw != null) 'rw': rw,
        if (ktpPhotoUrl != null) 'ktpPhotoUrl': ktpPhotoUrl,
        if (kycFaceUrl != null) 'kycFaceUrl': kycFaceUrl,
        if (gender != null) 'gender': gender,
        if (birthDate != null) 'birthDate': birthDate,
      };
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final User user;
  final bool deviceChanged;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.deviceChanged = false,
  });
}

abstract class AuthRepository {
  Future<Either<Failure, User>> register(RegisterParams params);
  Future<Either<Failure, AuthTokens>> login(
    String email,
    String password, {
    String? deviceId,
  });
  Future<Either<Failure, AuthTokens>> verifyPin(
    String pin,
    String refreshToken,
  );
  Future<Either<Failure, Map<String, dynamic>>> sendOtp(
    String email,
    String phone,
    String type,
  );
  Future<Either<Failure, bool>> verifyOtp(String otpId, String otpCode);
  Future<Either<Failure, bool>> checkAvailability(String email, String phone);
  Future<Either<Failure, bool>> checkUsername(String username);
}