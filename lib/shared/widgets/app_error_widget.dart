import 'package:flutter/material.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/shared/widgets/app_button.dart';
import 'package:bennett_campus/shared/widgets/app_card.dart';

/// Reusable error state widget with optional retry action.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.compact = false,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          compact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          width: compact ? 36 : 48,
          height: compact ? 36 : 48,
          decoration: const BoxDecoration(
            color: AppColors.errorMuted,
            borderRadius: AppRadii.borderMd,
          ),
          child: Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: compact ? 20 : 24,
          ),
        ),
        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
        Text(
          title,
          style: compact
              ? theme.textTheme.titleSmall
              : theme.textTheme.headlineSmall,
          textAlign: compact ? TextAlign.start : TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          message,
          style: theme.textTheme.bodyMedium,
          textAlign: compact ? TextAlign.start : TextAlign.center,
        ),
        if (onRetry != null) ...[
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: retryLabel,
            onPressed: onRetry,
            variant: AppButtonVariant.outline,
            size: compact ? AppButtonSize.sm : AppButtonSize.md,
            leadingIcon: Icons.refresh_rounded,
          ),
        ],
      ],
    );

    if (compact) {
      return AppCard(
        borderColor: AppColors.error.withValues(alpha: 0.35),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: body,
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: AppCard(
          borderColor: AppColors.error.withValues(alpha: 0.35),
          child: body,
        ),
      ),
    );
  }
}
