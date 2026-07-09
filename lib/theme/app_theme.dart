import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema ringan: kontras jelas, sedikit dekorasi (hemat repaint).
ThemeData buildUangKyTheme() {
  const peach = AppColors.peach;
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.inkPrimary,
      brightness: Brightness.light,
      primary: AppColors.inkPrimary,
      onPrimary: peach,
      surface: AppColors.scaffold,
      onSurface: AppColors.inkPrimary,
      onSurfaceVariant: AppColors.inkMuted,
      surfaceContainerHighest: AppColors.surfaceMuted,
      outlineVariant: AppColors.borderSoft,
      secondary: AppColors.inkSecondary,
      error: AppColors.expenseRed,
    ),
  );
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.scaffold,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.inkPrimary,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.borderSoft.withValues(alpha: 0.9)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.borderSoft.withValues(alpha: 0.9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.borderSoft.withValues(alpha: 0.9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.inkFocus, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.expenseRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.expenseRed, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.inkPrimary,
        foregroundColor: peach,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.card,
      indicatorColor: peach.withValues(alpha: 0.65),
      height: 60,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? AppColors.inkPrimary
              : AppColors.inkMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        return IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.inkPrimary
              : AppColors.inkMuted,
          size: 22,
        );
      }),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      minVerticalPadding: 8,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.inkPrimary,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
