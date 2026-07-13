import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationFormState {
  final String email;
  final String phone;
  final String otpId;
  final String username;
  final String profileImagePath;

  RegistrationFormState({
    this.email = '',
    this.phone = '',
    this.otpId = '',
    this.username = '',
    this.profileImagePath = '',
  });

  RegistrationFormState copyWith({
    String? email,
    String? phone,
    String? otpId,
    String? username,
    String? profileImagePath,
  }) {
    return RegistrationFormState(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      otpId: otpId ?? this.otpId,
      username: username ?? this.username,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}

final registrationFormProvider = StateProvider<RegistrationFormState>((ref) {
  return RegistrationFormState();
});
