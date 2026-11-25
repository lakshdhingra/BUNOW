import 'package:flutter/material.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/core/utils/external_links.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/shared/widgets/app_button.dart';
import 'package:bennett_campus/shared/widgets/campus_network_image.dart';

/// Opens a dark modal lightbox preview for a campus photograph with gallery navigation.
Future<void> showMediaPreviewDialog(
  BuildContext context,
  MediaItem item, {
  List<MediaItem>? gallery,
}) {
  final photos = (gallery ?? [item])
      .where((m) => m.kind == MediaKind.photo)
      .toList();
  final initialIndex = photos.indexWhere((p) => p.id == item.id);
  var currentIndex = initialIndex < 0 ? 0 : initialIndex;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        final active = photos.isEmpty ? item : photos[currentIndex];
        return Dialog(
          backgroundColor: AppColors.surface,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CampusNetworkImage(
                      imageUrl: active.url,
                      height: 380,
                      width: double.infinity,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadii.lg - 1),
                      ),
                    ),
                    if (photos.length > 1) ...[
                      Positioned(
                        left: AppSpacing.sm,
                        child: IconButton.filled(
                          onPressed: currentIndex > 0
                              ? () => setState(() => currentIndex -= 1)
                              : null,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.background.withValues(
                              alpha: 0.78,
                            ),
                          ),
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                      ),
                      Positioned(
                        right: AppSpacing.sm,
                        child: IconButton.filled(
                          onPressed: currentIndex < photos.length - 1
                              ? () => setState(() => currentIndex += 1)
                              : null,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.background.withValues(
                              alpha: 0.78,
                            ),
                          ),
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                      ),
                    ],
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              active.caption,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textPrimary),
                            ),
                            if (photos.length > 1)
                              Text(
                                'Photo ${currentIndex + 1} of ${photos.length}',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        tooltip: 'Close preview',
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// Opens an interactive promotional/recap video embed preview modal.
Future<void> showVideoEmbedDialog(BuildContext context, MediaItem video) {
  var isPlaying = true;
  var progress = 0.35;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        final theme = Theme.of(context);
        return Dialog(
          backgroundColor: AppColors.surface,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CampusNetworkImage(
                      imageUrl: video.thumbnailUrl ?? video.url,
                      height: 320,
                      width: double.infinity,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadii.lg - 1),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.48),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppRadii.lg - 1),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton.filled(
                          iconSize: 40,
                          onPressed: () =>
                              setState(() => isPlaying = !isPlaying),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.all(AppSpacing.md),
                          ),
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background.withValues(alpha: 0.85),
                            borderRadius: AppRadii.borderPill,
                          ),
                          child: Text(
                            isPlaying
                                ? 'Playing Preview · ${video.durationLabel ?? '01:30'}'
                                : 'Paused · ${video.durationLabel ?? '01:30'}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      bottom: AppSpacing.sm,
                      child: Slider(
                        value: progress,
                        activeColor: AppColors.secondary,
                        inactiveColor: AppColors.border,
                        onChanged: (val) => setState(() => progress = val),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.section.label.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                            Text(video.caption, style: theme.textTheme.titleMedium),
                          ],
                        ),
                      ),
                      Wrap(
                        spacing: AppSpacing.xs,
                        children: [
                          AppButton(
                            label: 'Open Source',
                            variant: AppButtonVariant.outline,
                            size: AppButtonSize.sm,
                            leadingIcon: Icons.open_in_new_rounded,
                            onPressed: () => launchExternalUrl(
                              context,
                              video.url,
                              label: video.caption,
                            ),
                          ),
                          AppButton(
                            label: 'Close',
                            variant: AppButtonVariant.ghost,
                            size: AppButtonSize.sm,
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
