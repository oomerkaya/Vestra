import 'package:flutter/material.dart';

/// Raw palette. Widgets should read colors from `Theme.of(context)` or
/// `context.vestraColors`, never from here directly.
abstract final class AppPalette {
  // Brand accent (indigo).
  static const Color accent = Color(0xFF4F5BD5);
  static const Color accentDark = Color(0xFF8B95FF);

  // Light neutrals.
  static const Color lightBackground = Color(0xFFF5F6F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFEEF0F3);
  static const Color lightTextPrimary = Color(0xFF111318);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightDivider = Color(0xFFE5E7EB);

  // Dark neutrals.
  static const Color darkBackground = Color(0xFF0D0F12);
  static const Color darkSurface = Color(0xFF16191E);
  static const Color darkSurfaceMuted = Color(0xFF1F232A);
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkDivider = Color(0xFF262B33);

  // Semantic.
  static const Color gainLight = Color(0xFF15803D);
  static const Color gainDark = Color(0xFF34D399);
  static const Color lossLight = Color(0xFFDC2626);
  static const Color lossDark = Color(0xFFF87171);

  // Asset type accents (for avatars and small markers only).
  static const Color currency = Color(0xFF3B82F6);
  static const Color gold = Color(0xFFD4A017);
  static const Color silver = Color(0xFF94A3B8);
  static const Color stock = Color(0xFF8B5CF6);
}

/// Colors that Material's [ColorScheme] does not cover.
@immutable
class VestraColors extends ThemeExtension<VestraColors> {
  const VestraColors({
    required this.gain,
    required this.loss,
    required this.gainContainer,
    required this.lossContainer,
    required this.textSecondary,
    required this.surfaceMuted,
  });

  static const light = VestraColors(
    gain: AppPalette.gainLight,
    loss: AppPalette.lossLight,
    gainContainer: Color(0xFFE7F6EC),
    lossContainer: Color(0xFFFDECEC),
    textSecondary: AppPalette.lightTextSecondary,
    surfaceMuted: AppPalette.lightSurfaceMuted,
  );

  static const dark = VestraColors(
    gain: AppPalette.gainDark,
    loss: AppPalette.lossDark,
    gainContainer: Color(0xFF0F2A20),
    lossContainer: Color(0xFF2E1517),
    textSecondary: AppPalette.darkTextSecondary,
    surfaceMuted: AppPalette.darkSurfaceMuted,
  );

  final Color gain;
  final Color loss;
  final Color gainContainer;
  final Color lossContainer;
  final Color textSecondary;
  final Color surfaceMuted;

  @override
  VestraColors copyWith({
    Color? gain,
    Color? loss,
    Color? gainContainer,
    Color? lossContainer,
    Color? textSecondary,
    Color? surfaceMuted,
  }) => VestraColors(
    gain: gain ?? this.gain,
    loss: loss ?? this.loss,
    gainContainer: gainContainer ?? this.gainContainer,
    lossContainer: lossContainer ?? this.lossContainer,
    textSecondary: textSecondary ?? this.textSecondary,
    surfaceMuted: surfaceMuted ?? this.surfaceMuted,
  );

  @override
  VestraColors lerp(VestraColors? other, double t) {
    if (other == null) return this;
    return VestraColors(
      gain: Color.lerp(gain, other.gain, t)!,
      loss: Color.lerp(loss, other.loss, t)!,
      gainContainer: Color.lerp(gainContainer, other.gainContainer, t)!,
      lossContainer: Color.lerp(lossContainer, other.lossContainer, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
    );
  }
}

extension VestraColorsX on BuildContext {
  VestraColors get vestraColors => Theme.of(this).extension<VestraColors>()!;
}
