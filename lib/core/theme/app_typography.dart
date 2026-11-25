import 'package:flutter/material.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';

/// Centralized Material 3 typography scale for the BENNETT platform.
abstract final class AppTypography {
  static const List<String> _fontFallback = <String>[
    'Inter',
    'Segoe UI',
    'Roboto',
    'sans-serif',
  ];

  static TextTheme get textTheme => const TextTheme(
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.9,
      height: 1.15,
      color: AppColors.textPrimary,
      fontFamilyFallback: _fontFallback,
    ),
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
      height: 1.2,
      color: AppColors.textPrimary,
      fontFamilyFallback: _fontFallback,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.4,
      height: 1.25,
      color: AppColors.textPrimary,
      fontFamilyFallback: _fontFallback,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      height: 1.3,
      color: AppColors.textPrimary,
      fontFamilyFallback: _fontFallback,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      height: 1.35,
      color: AppColors.textPrimary,
      fontFamilyFallback: _fontFallback,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: AppColors.textPrimary,
      fontFamilyFallback: _fontFallback,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.textPrimary,
      fontFamilyFallback: _fontFallback,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.textSecondary,
      fontFamilyFallback: _fontFallback,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: AppColors.textSecondary,
      fontFamilyFallback: _fontFallback,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.2,
      color: AppColors.textPrimary,
      fontFamilyFallback: _fontFallback,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      height: 1.2,
      color: AppColors.textSecondary,
      fontFamilyFallback: _fontFallback,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      height: 1.2,
      color: AppColors.textMuted,
      fontFamilyFallback: _fontFallback,
    ),
  );
}
