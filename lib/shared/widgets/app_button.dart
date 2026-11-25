import 'package:flutter/material.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }

enum AppButtonSize { sm, md, lg }

/// Reusable action button aligned with the BENNETT design system.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool fullWidth;

  double get _height => switch (size) {
    AppButtonSize.sm => 36,
    AppButtonSize.md => 44,
    AppButtonSize.lg => 50,
  };

  EdgeInsets get _padding => switch (size) {
    AppButtonSize.sm => const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    AppButtonSize.md => const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    AppButtonSize.lg => const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
  };

  double get _iconSize => switch (size) {
    AppButtonSize.sm => 16,
    AppButtonSize.md => 18,
    AppButtonSize.lg => 20,
  };

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final child = _buildContent(context);

    final Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          minimumSize: Size(0, _height),
          padding: _padding,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
        ),
        child: child,
      ),
      AppButtonVariant.secondary => ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.background,
          minimumSize: Size(0, _height),
          padding: _padding,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
        ),
        child: child,
      ),
      AppButtonVariant.outline => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: Size(0, _height),
          padding: _padding,
          side: const BorderSide(color: AppColors.border),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
        ),
        child: child,
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: effectiveOnPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          minimumSize: Size(0, _height),
          padding: _padding,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
        ),
        child: child,
      ),
    };

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Widget _buildContent(BuildContext context) {
    final Color foreground = switch (variant) {
      AppButtonVariant.secondary => AppColors.background,
      AppButtonVariant.ghost => AppColors.textSecondary,
      _ => AppColors.textPrimary,
    };

    if (isLoading) {
      return SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(foreground),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: _iconSize),
          const SizedBox(width: AppSpacing.xs),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Icon(trailingIcon, size: _iconSize),
        ],
      ],
    );
  }
}
