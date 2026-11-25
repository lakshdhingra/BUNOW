import 'package:flutter/material.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/shared/widgets/app_card.dart';
import 'package:bennett_campus/shared/widgets/campus_network_image.dart';

/// Reusable card displaying a Bennett University club or student chapter.
class ClubCard extends StatelessWidget {
  const ClubCard({
    super.key,
    required this.club,
    this.onTap,
  });

  final CampusClub club;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CampusNetworkImage(
                imageUrl: club.coverUrl,
                height: 108,
                width: double.infinity,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadii.lg - 1),
                ),
                fallbackIcon: Icons.groups_2_outlined,
              ),
              Positioned(
                bottom: -18,
                left: AppSpacing.md,
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppRadii.borderMd,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Text(
                    club.shortCode,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg + 4,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        club.name,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (club.isVerified) ...[
                      const SizedBox(width: AppSpacing.xxs),
                      const Icon(
                        Icons.verified_rounded,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  club.category,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primaryHover,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  club.tagline,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _ClubMeta(
                      icon: Icons.people_outline_rounded,
                      label: '${club.memberCount} members',
                    ),
                    _ClubMeta(
                      icon: Icons.event_note_outlined,
                      label: '${club.upcomingEventCount} upcoming',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubMeta extends StatelessWidget {
  const _ClubMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
