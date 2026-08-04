import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String fullName,
    required String username,
    required String role,
    String? phone,
    String? pinHash,
    String? nik,
    String? province,
    String? city,
    String? district,
    String? village,
    String? postalCode,
    String? rt,
    String? rw,
    String? ktpPhotoUrl,
    String? profilePhotoUrl,
    String? kycFaceUrl,
    String? kycStatus,
    String? publicKeyB64,
    String? gender,
    String? birthDate,
  }) = _User;
}