import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const String fontFamily = 'Inter';

  /// Equal-width digits so amounts line up in lists.
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static TextTheme textTheme(Color primary, Color secondary) => TextTheme(
    displaySmall: _s(34, FontWeight.w700, primary, -0.8, tabular: true),
    headlineMedium: _s(28, FontWeight.w700, primary, -0.6),
    headlineSmall: _s(24, FontWeight.w700, primary, -0.4),
    titleLarge: _s(20, FontWeight.w600, primary, -0.3),
    titleMedium: _s(16, FontWeight.w600, primary, -0.1),
    titleSmall: _s(14, FontWeight.w600, primary, 0),
    bodyLarge: _s(16, FontWeight.w400, primary, -0.1),
    bodyMedium: _s(14, FontWeight.w400, primary, 0),
    bodySmall: _s(12, FontWeight.w400, secondary, 0),
    labelLarge: _s(14, FontWeight.w600, primary, 0),
    labelMedium: _s(12, FontWeight.w500, secondary, 0.1),
    labelSmall: _s(11, FontWeight.w500, secondary, 0.2),
  );

  static TextStyle _s(
    double size,
    FontWeight weight,
    Color color,
    double letterSpacing, {
    bool tabular = false,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: 1.25,
    fontFeatures: tabular ? AppTypography.tabular : null,
  );
}
