import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/core/utils/external_links.dart';
import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/presentation/providers/student_portal_providers.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/event_card.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/media_preview_dialog.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/section_header.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Individual Bennett University club profile page.
class ClubProfilePage extends ConsumerWidget {
  const ClubProfilePage({super.key, required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final club = MockCampusData.clubs
        .where((c) => c.id == clubId)
        .firstOrNull;

    if (club == null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppErrorWidget(
          title: 'Club not found',
          message: 'We could not find a club matching "$clubId".',
          retryLabel: 'Back to Clubs',
          onRetry: () => context.go(AppRoutes.clubs),
        ),
      );
    }

    final registeredIds = ref.watch(registeredEventIdsProvider);
    final upcomingEvents = MockCampusData.events
        .where((event) => event.clubId == club.id)
        .toList();

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.clubs),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to Clubs Directory'),
            ),
            const SizedBox(height: AppSpacing.md),
            _ClubBrandingHeader(club: club),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About ${club.name}', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Text(club.about, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SectionHeader(
              title: 'Upcoming Events',
              subtitle: 'Active sessions and registrations by ${club.shortCode}',
            ),
            const SizedBox(height: AppSpacing.md),
            if (upcomingEvents.isEmpty)
              AppCard(
                child: Text(
                  'No upcoming events scheduled right now. Check back soon.',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              ResponsiveCardGrid(
                children: upcomingEvents.map((event) {
                  final isRegistered = registeredIds.contains(event.id);
                  return EventCard(
                    event: event,
                    isRegistered: isRegistered,
                    onTap: () => context.go(AppRoutes.eventDetail(event.id)),
                    onActionTap: () {
                      final activeReg = ref.read(
                        activeRegistrationForEventProvider(event.id),
                      );
                      if (activeReg != null) {
                        context.go(AppRoutes.ticketDetail(activeReg.id));
                      } else if (event.isFull || event.isRegistrationClosed) {
                        context.go(AppRoutes.eventDetail(event.id));
                      } else {
                        context.go(AppRoutes.eventRegistration(event.id));
                      }
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: AppSpacing.xxl),
            const SectionHeader(
              title: 'Previous Events',
              subtitle: 'Past campus initiatives and milestones',
            ),
            const SizedBox(height: AppSpacing.md),
            if (club.previousEvents.isEmpty)
              AppCard(
                child: Text(
                  'Previous event archive will appear here.',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              ResponsiveCardGrid(
                children: club.previousEvents.map((prev) {
                  return AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CampusNetworkImage(
                          imageUrl: prev.coverUrl,
                          height: 148,
                          width: double.infinity,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppRadii.lg - 1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${prev.dateLabel} · ${prev.attendeesLabel}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(prev.title, style: theme.textTheme.titleMedium),
                              const SizedBox(height: AppSpacing.xs),
                              Text(prev.summary, style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: AppSpacing.xxl),
            const SectionHeader(
              title: 'Photographs',
              subtitle: 'Highlights captured during club events',
            ),
            const SizedBox(height: AppSpacing.md),
            if (club.photos.isEmpty)
              AppCard(
                child: Text(
                  'No photographs published yet for this club.',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              ResponsiveCardGrid(
                children: club.photos.map((photo) {
                  return AppCard(
                    padding: EdgeInsets.zero,
                    onTap: () => showMediaPreviewDialog(context, photo),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CampusNetworkImage(
                          imageUrl: photo.url,
                          height: 172,
                          width: double.infinity,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppRadii.lg - 1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            photo.caption,
                            style: theme.textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: AppSpacing.xxl),
            const SectionHeader(
              title: 'Videos',
              subtitle: 'Aftermovies, demos, and session recordings',
            ),
            const SizedBox(height: AppSpacing.md),
            if (club.videos.isEmpty)
              AppCard(
                child: Text(
                  'No video highlights uploaded yet for this club.',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              ResponsiveCardGrid(
                children: club.videos.map((video) {
                  return AppCard(
                    padding: EdgeInsets.zero,
                    onTap: () => launchExternalUrl(
                      context,
                      video.videoUrl,
                      label: video.title,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CampusNetworkImage(
                              imageUrl: video.thumbnailUrl,
                              height: 164,
                              width: double.infinity,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppRadii.lg - 1),
                              ),
                            ),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.background.withValues(
                                  alpha: 0.85,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: AppColors.textPrimary,
                                size: 28,
                              ),
                            ),
                            Positioned(
                              bottom: AppSpacing.sm,
                              right: AppSpacing.sm,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.background.withValues(
                                    alpha: 0.85,
                                  ),
                                  borderRadius: AppRadii.borderSm,
                                ),
                                child: Text(
                                  video.durationLabel,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(video.title, style: theme.textTheme.titleMedium),
                              const SizedBox(height: AppSpacing.xs),
                              Text(video.summary, style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: AppSpacing.xxl),
            const SectionHeader(
              title: 'Club Leadership',
              subtitle: 'Authorized student coordinators & chapter leads',
            ),
            const SizedBox(height: AppSpacing.md),
            ResponsiveCardGrid(
              children: club.leadership.map((leader) {
                return AppCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryMuted,
                        child: Text(
                          leader.initials,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.primaryHover,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(leader.name, style: theme.textTheme.titleSmall),
                            Text(
                              leader.role,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                            Text(
                              leader.program,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClubBrandingHeader extends StatelessWidget {
  const _ClubBrandingHeader({required this.club});

  final CampusClub club;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = DeviceScreenType.of(context) == DeviceScreenType.mobile;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CampusNetworkImage(
                imageUrl: club.coverUrl,
                height: isMobile ? 160 : 210,
                width: double.infinity,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadii.lg - 1),
                ),
              ),
              Positioned(
                bottom: -26,
                left: AppSpacing.lg,
                child: Container(
                  width: 68,
                  height: 68,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppRadii.borderLg,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Text(
                    club.shortCode,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl + 8,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      club.name,
                      style: isMobile
                          ? theme.textTheme.headlineMedium
                          : theme.textTheme.headlineLarge,
                    ),
                    if (club.isVerified)
                      const Icon(
                        Icons.verified_rounded,
                        size: 20,
                        color: AppColors.secondary,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${club.category} · ${club.memberCount} members',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primaryHover,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(club.tagline, style: theme.textTheme.bodyLarge),
                if (club.socialLinks.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: club.socialLinks.map((link) {
                      return AppButton(
                        label: '${link.platform} · ${link.handle}',
                        variant: AppButtonVariant.outline,
                        size: AppButtonSize.sm,
                        leadingIcon: Icons.open_in_new_rounded,
                        onPressed: () => launchExternalUrl(
                          context,
                          link.url,
                          label: link.platform,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
