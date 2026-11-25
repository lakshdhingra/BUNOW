import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/shared/widgets/app_button.dart';
import 'package:bennett_campus/shared/widgets/campus_network_image.dart';
import 'package:bennett_campus/shared/widgets/responsive_layout.dart';

/// Hero banner showcasing the flagship featured campus event.
class FeaturedEventBanner extends StatelessWidget {
  const FeaturedEventBanner({
    super.key,
    required this.event,
    required this.isRegistered,
    required this.onRegisterTap,
    required this.onDetailsTap,
  });

  final CampusEvent event;
  final bool isRegistered;
  final VoidCallback onRegisterTap;
  final VoidCallback onDetailsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = DeviceScreenType.of(context) == DeviceScreenType.mobile;
    final dateLabel = DateFormat('EEE, d MMM · h:mm a').format(event.startTime);

    return ClipRRect(
      borderRadius: AppRadii.borderXl,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.borderXl,
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CampusNetworkImage(
                imageUrl: event.bannerUrl,
                fit: BoxFit.cover,
                fallbackIcon: Icons.auto_awesome_outlined,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.background.withValues(alpha: 0.95),
                      AppColors.background.withValues(alpha: 0.82),
                      AppColors.background.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _FeaturedBadge(
                          label: 'FEATURED EVENT',
                          color: AppColors.primary,
                        ),
                        _FeaturedBadge(
                          label: event.clubName,
                          color: AppColors.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      event.title,
                      style: isMobile
                          ? theme.textTheme.headlineMedium
                          : theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      event.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.lg,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _MetaInfo(
                          icon: Icons.calendar_today_outlined,
                          text: dateLabel,
                        ),
                        _MetaInfo(
                          icon: Icons.location_on_outlined,
                          text: event.venue,
                        ),
                        _MetaInfo(
                          icon: Icons.people_outline_rounded,
                          text:
                              '${event.registeredCount}/${event.capacity} registered',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        AppButton(
                          label: isRegistered
                              ? 'Registered · View Pass'
                              : 'Register Now',
                          variant: isRegistered
                              ? AppButtonVariant.secondary
                              : AppButtonVariant.primary,
                          leadingIcon: isRegistered
                              ? Icons.check_circle_outline_rounded
                              : Icons.confirmation_number_outlined,
                          onPressed: onRegisterTap,
                        ),
                        AppButton(
                          label: 'Event Details',
                          variant: AppButtonVariant.outline,
                          onPressed: onDetailsTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedBadge extends StatelessWidget {
  const _FeaturedBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: AppRadii.borderPill,
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _MetaInfo extends StatelessWidget {
  const _MetaInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.secondary),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
