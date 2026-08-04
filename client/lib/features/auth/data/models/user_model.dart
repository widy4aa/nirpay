import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
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
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

extension UserModelX on UserModel {
  User toEntity() => User(
        id: id,
        email: email,
        fullName: fullName,
        username: username,
        role: role,
        phone: phone,
        pinHash: pinHash,
        nik: nik,
        province: province,
        city: city,
        district: district,
        village: village,
        postalCode: postalCode,
        rt: rt,
        rw: rw,
        ktpPhotoUrl: ktpPhotoUrl,
        profilePhotoUrl: profilePhotoUrl,
        kycFaceUrl: kycFaceUrl,
        kycStatus: kycStatus,
        publicKeyB64: publicKeyB64,
        gender: gender,
        birthDate: birthDate,
      );
}