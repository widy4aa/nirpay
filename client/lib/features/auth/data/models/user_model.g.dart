// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      pinHash: json['pinHash'] as String?,
      nik: json['nik'] as String?,
      province: json['province'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      village: json['village'] as String?,
      postalCode: json['postalCode'] as String?,
      rt: json['rt'] as String?,
      rw: json['rw'] as String?,
      ktpPhotoUrl: json['ktpPhotoUrl'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      kycFaceUrl: json['kycFaceUrl'] as String?,
      kycStatus: json['kycStatus'] as String?,
      publicKeyB64: json['publicKeyB64'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birthDate'] as String?,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'username': instance.username,
      'role': instance.role,
      'phone': instance.phone,
      'pinHash': instance.pinHash,
      'nik': instance.nik,
      'province': instance.province,
      'city': instance.city,
      'district': instance.district,
      'village': instance.village,
      'postalCode': instance.postalCode,
      'rt': instance.rt,
      'rw': instance.rw,
      'ktpPhotoUrl': instance.ktpPhotoUrl,
      'profilePhotoUrl': instance.profilePhotoUrl,
      'kycFaceUrl': instance.kycFaceUrl,
      'kycStatus': instance.kycStatus,
      'publicKeyB64': instance.publicKeyB64,
      'gender': instance.gender,
      'birthDate': instance.birthDate,
    };
