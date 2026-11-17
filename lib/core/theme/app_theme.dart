import 'package:flutter/material.dart';
import 'package:vestra/core/theme/app_colors.dart';
import 'package:vestra/core/theme/app_tokens.dart';
import 'package:vestra/core/theme/app_typography.dart';

/// "Clean fintech" theme: neutral backgrounds, borderless white/graphite
/// cards, a single indigo accent, green/red reserved for gain/loss.
abstract final class AppTheme {
  static ThemeData get light => _build(
    brightness: Brightness.light,
    accent: AppPalette.accent,
    background: AppPalette.lightBackground,
    surface: AppPalette.lightSurface,
    surfaceMuted: AppPalette.lightSurfaceMuted,
    textPrimary: AppPalette.lightTextPrimary,
    textSecondary: AppPalette.lightTextSecondary,
    divider: AppPalette.lightDivider,
    error: AppPalette.lossLight,
    extension: VestraColors.light,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    accent: AppPalette.accentDark,
    background: AppPalette.darkBackground,
    surface: AppPalette.darkSurface,
    surfaceMuted: AppPalette.darkSurfaceMuted,
    textPrimary: AppPalette.darkTextPrimary,
    textSecondary: AppPalette.darkTextSecondary,
    divider: AppPalette.darkDivider,
    error: AppPalette.lossDark,
    extension: VestraColors.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color accent,
    required Color background,
    required Color surface,
    required Color surfaceMuted,
    required Color textPrimary,
    required Color textSecondary,
    required Color divider,
    required Color error,
    required VestraColors extension,
  }) {
    final isDark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: brightness,
        ).copyWith(
          primary: accent,
          onPrimary: isDark ? AppPalette.darkBackground : Colors.white,
          surface: background,
          onSurface: textPrimary,
          onSurfaceVariant: textSecondary,
          surfaceContainerLowest: surface,
          surfaceContainerLow: surface,
          surfaceContainer: surface,
          surfaceContainerHigh: surfaceMuted,
          surfaceContainerHighest: surfaceMuted,
          outline: divider,
          outlineVariant: divider,
          error: error,
        );
    final text = AppTypography.textTheme(textPrimary, textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppTypography.fontFamily,
      textTheme: text,
      scaffoldBackgroundColor: background,
      extensions: [extension],
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleSpacing: AppSpacing.screen,
        titleTextStyle: text.headlineSmall,
        foregroundColor: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: accent.withValues(alpha: isDark ? 0.18 : 0.12),
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? accent
                : textSecondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium!.copyWith(
            color: states.contains(WidgetState.selected)
                ? textPrimary
                : textSecondary,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          textStyle: text.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          side: BorderSide(color: divider),
          foregroundColor: textPrimary,
          textStyle: text.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide(color: error),
        ),
        hintStyle: text.bodyLarge?.copyWith(color: textSecondary),
        labelStyle: text.bodyMedium?.copyWith(color: textSecondary),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        iconColor: textSecondary,
        titleTextStyle: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        subtitleTextStyle: text.bodySmall,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        backgroundColor: isDark ? surfaceMuted : textPrimary,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: isDark ? textPrimary : Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        highlightElevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),
    );
  }
}
