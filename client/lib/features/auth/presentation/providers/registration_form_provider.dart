import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationFormState {
  final String email;
  final String phone;
  final String otpId;
  final String fullName;
  final String nik;
  final String province;
  final String city;
  final String district;
  final String village;
  final String postalCode;
  final String rt;
  final String rw;
  final String ktpPhotoUrl;
  final String kycFaceUrl;
  final String username;
  final String password;
  final String gender;
  final String birthDate;

  RegistrationFormState({
    this.email = '',
    this.phone = '',
    this.otpId = '',
    this.fullName = '',
    this.nik = '',
    this.province = '',
    this.city = '',
    this.district = '',
    this.village = '',
    this.postalCode = '',
    this.rt = '',
    this.rw = '',
    this.ktpPhotoUrl = '',
    this.kycFaceUrl = '',
    this.username = '',
    this.password = '',
    this.gender = '',
    this.birthDate = '',
  });

  RegistrationFormState copyWith({
    String? email,
    String? phone,
    String? otpId,
    String? fullName,
    String? nik,
    String? province,
    String? city,
    String? district,
    String? village,
    String? postalCode,
    String? rt,
    String? rw,
    String? ktpPhotoUrl,
    String? kycFaceUrl,
    String? username,
    String? password,
    String? gender,
    String? birthDate,
  }) {
    return RegistrationFormState(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      otpId: otpId ?? this.otpId,
      fullName: fullName ?? this.fullName,
      nik: nik ?? this.nik,
      province: province ?? this.province,
      city: city ?? this.city,
      district: district ?? this.district,
      village: village ?? this.village,
      postalCode: postalCode ?? this.postalCode,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      ktpPhotoUrl: ktpPhotoUrl ?? this.ktpPhotoUrl,
      kycFaceUrl: kycFaceUrl ?? this.kycFaceUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}

final registrationFormProvider = StateProvider<RegistrationFormState>((ref) {
  return RegistrationFormState();
});
