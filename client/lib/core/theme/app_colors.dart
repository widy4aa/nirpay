import 'package:flutter/material.dart';

abstract class AppColors {
  // Static const lama (untuk compatibility sementara)
  static const primary = Color(0xFF009CFF);
  static const success = Color(0xFF26644A);
  static const error = Color(0xFFD63C42);
  static const warning = Color(0xFFFF9500);
  static const background = Color(0xFFF4F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1E1E24);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE2E6EE);
}

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primary;
  final Color success;
  final Color error;
  final Color warning;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  const AppColorsExtension({
    required this.primary,
    required this.success,
    required this.error,
    required this.warning,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  static const light = AppColorsExtension(
    primary: Color(0xFF009CFF),
    success: Color(0xFF26644A),
    error: Color(0xFFD63C42),
    warning: Color(0xFFFF9500),
    background: Color(0xFFF4F7FB),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1E1E24),
    textSecondary: Color(0xFF6B7280),
    border: Color(0xFFE2E6EE),
  );

  static const dark = AppColorsExtension(
    primary: Color(0xFF009CFF),
    success: Color(0xFF348F69),
    error: Color(0xFFE65C62),
    warning: Color(0xFFFFB340),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA0A0A0),
    border: Color(0xFF333333),
  );

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? primary,
    Color? success,
    Color? error,
    Color? warning,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

extension BuildContextColors on BuildContext {
  AppColorsExtension get colors => Theme.of(this).extension<AppColorsExtension>()!;
}
