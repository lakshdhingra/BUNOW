import 'package:flutter/material.dart';

/// Centralized color tokens for the BENNETT dark-mode design system.
abstract final class AppColors {
  // Core canvas & surface hierarchy
  static const Color background = Color(0xFF090D18);
  static const Color surface = Color(0xFF151B2B);
  static const Color surfaceElevated = Color(0xFF1C2438);
  static const Color surfaceHover = Color(0xFF212B42);
  static const Color border = Color(0xFF252F47);
  static const Color borderSubtle = Color(0xFF1D253A);

  // Brand accents
  static const Color primary = Color(0xFF7554DF);
  static const Color primaryHover = Color(0xFF8668E8);
  static const Color primaryPressed = Color(0xFF6343CC);
  static const Color primaryMuted = Color(0x267554DF);

  static const Color secondary = Color(0xFF39B8ED);
  static const Color secondaryHover = Color(0xFF56C4F2);
  static const Color secondaryMuted = Color(0x2439B8ED);

  // Typography
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAB4C7);
  static const Color textMuted = Color(0xFF727E96);

  // Semantic feedback
  static const Color success = Color(0xFF22C55E);
  static const Color successMuted = Color(0x2422C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningMuted = Color(0x24F59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorMuted = Color(0x24EF4444);
}
