import 'package:flutter/material.dart';

/// Warna utama UangKy: peach sebagai aksen, netral untuk area baca panjang.
abstract final class AppColors {
  static const Color peach = Color(0xFFFFCC99);
  static const Color inkPrimary = Color(0xFF1C1917);
  static const Color inkSecondary = Color(0xFF44403C);

  /// Subtitle & helper — ≥4.5:1 on scaffold (#F6F4F1) and card.
  static const Color inkMuted = Color(0xFF57534E);
  static const Color inkFocus = Color(0xFF57534E);
  static const Color textPrimary = inkPrimary;
  static const Color textSecondary = inkSecondary;
  static const Color textMuted = inkMuted;
  static const Color onInk = Color(0xFFFFFFFF);
  static const Color inkScrim = Color(0x14000000);
  static const Color scaffold = Color(0xFFF6F4F1);
  static const Color card = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFECE8E3);
  static const Color surfaceGlass = Color(0xE6FFFFFF);
  static const Color borderSoft = Color(0x22000000);
  static const Color chartGreen = Color(0xFF22C55E);
  static const Color chartRed = Color(0xFFEF4444);
  static const Color incomeGreen = Color(0xFF15803D);
  static const Color expenseRed = Color(0xFFB91C1C);
}
