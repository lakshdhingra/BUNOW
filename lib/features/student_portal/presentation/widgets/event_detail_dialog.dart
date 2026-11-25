import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/shared/widgets/app_button.dart';
import 'package:bennett_campus/shared/widgets/campus_network_image.dart';

/// Displays an interactive Stage 1 preview dialog for a campus event.
Future<void> showEventPreviewDialog({
  required BuildContext context,
  required CampusEvent event,
  required bool isRegistered,
  required VoidCallback onToggleRegistration,
}) {
  final theme = Theme.of(context);
  final dateLabel = DateFormat('EEEE, d MMM yyyy · h:mm a').format(event.startTime);

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CampusNetworkImage(
                imageUrl: event.bannerUrl,
                height: 200,
                width: double.infinity,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadii.lg - 1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${event.category.label} · ${event.clubName}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(event.title, style: theme.textTheme.headlineMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(event.subtitle, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            dateLabel,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            event.venue,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    if (event.tags.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: event.tags
                            .map((tag) => Chip(label: Text(tag)))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppButton(
                          label: 'Close',
                          variant: AppButtonVariant.ghost,
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppButton(
                          label: isRegistered
                              ? 'Cancel Mock Pass'
                              : 'Mock Register',
                          variant: isRegistered
                              ? AppButtonVariant.outline
                              : AppButtonVariant.primary,
                          onPressed: () {
                            onToggleRegistration();
                            Navigator.of(dialogContext).pop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
