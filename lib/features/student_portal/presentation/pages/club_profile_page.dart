import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/core/utils/external_links.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/presentation/providers/student_portal_providers.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/category_chip.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/event_card.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/media_preview_dialog.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/section_header.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Individual Bennett University club profile page connected to Supabase.
class ClubProfilePage extends ConsumerWidget {
  const ClubProfilePage({super.key, required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final detailAsync = ref.watch(clubDetailProvider(clubId));
    final registeredIds = ref.watch(registeredEventIdsProvider);

    return detailAsync.when(
      loading: () => const AppLoadingIndicator(message: 'Loading club profile...'),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppErrorWidget(
          title: 'Unable to load club profile',
          message: error.toString(),
          onRetry: () => ref.invalidate(clubDetailProvider(clubId)),
        ),
      ),
      data: (detail) {
        final club = detail.club;
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

        final upcomingEvents = detail.events
            .where((event) => !event.isCompleted)
            .toList();
        final completedEvents = detail.events
            .where((event) => event.isCompleted)
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
                      Text(
                        'About ${club.name}',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        club.about.isNotEmpty
                            ? club.about
                            : 'Official Bennett University student organization.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                SectionHeader(
                  title: 'Upcoming Events',
                  subtitle: 'Active sessions and registrations by ${club.name}',
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
                          } else if (event.isFull ||
                              event.isRegistrationClosed) {
                            context.go(AppRoutes.eventDetail(event.id));
                          } else {
                            context.go(AppRoutes.eventRegistration(event.id));
                          }
                        },
                      );
                    }).toList(),
                  ),
                if (completedEvents.isNotEmpty ||
                    club.previousEvents.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  const SectionHeader(
                    title: 'Previous Events',
                    subtitle: 'Past campus initiatives and milestones',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ResponsiveCardGrid(
                    children: [
                      ...completedEvents.map((e) {
                        return EventCard(
                          event: e,
                          isRegistered: registeredIds.contains(e.id),
                          onTap: () => context.go(AppRoutes.eventDetail(e.id)),
                        );
                      }),
                      ...club.previousEvents.map((prev) {
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
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(color: AppColors.secondary),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      prev.title,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      prev.summary,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
                _ClubMediaLibrarySection(club: club, events: detail.events),
                if (club.leadership.isNotEmpty) ...[
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
                                  Text(
                                    leader.name,
                                    style: theme.textTheme.titleSmall,
                                  ),
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
              ],
            ),
          ),
        );
      },
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
                  child: (club.logoUrl != null && club.logoUrl!.isNotEmpty)
                      ? CampusNetworkImage(
                          imageUrl: club.logoUrl!,
                          width: 64,
                          height: 64,
                          borderRadius: AppRadii.borderMd,
                        )
                      : Text(
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
                        label: link.platform,
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

class _ClubMediaLibrarySection extends StatefulWidget {
  const _ClubMediaLibrarySection({
    required this.club,
    required this.events,
  });

  final CampusClub club;
  final List<CampusEvent> events;

  @override
  State<_ClubMediaLibrarySection> createState() =>
      _ClubMediaLibrarySectionState();
}

class _ClubMediaLibrarySectionState extends State<_ClubMediaLibrarySection> {
  MediaKind? _kindFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allMedia = <MediaItem>[
      ...widget.club.photos,
      ...widget.club.videos.map(
        (v) => MediaItem(
          id: 'club-vid-${v.title}',
          url: v.videoUrl,
          thumbnailUrl: v.thumbnailUrl,
          caption: v.title,
          kind: MediaKind.video,
          section: MediaSection.recap,
          durationLabel: v.durationLabel,
        ),
      ),
      for (final e in widget.events) ...[
        ...e.mediaGallery,
        ...e.promoVideos,
        ...e.recapMedia,
      ],
    ]..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final filtered = _kindFilter == null
        ? allMedia
        : allMedia.where((m) => m.kind == _kindFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Club Media Library',
          subtitle: 'Event photographs, promotional videos, and recap media',
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: CategoryChip(
                  label: 'All Media (${allMedia.length})',
                  isSelected: _kindFilter == null,
                  onTap: () => setState(() => _kindFilter = null),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: CategoryChip(
                  label: 'Photos',
                  isSelected: _kindFilter == MediaKind.photo,
                  onTap: () => setState(() => _kindFilter = MediaKind.photo),
                ),
              ),
              CategoryChip(
                label: 'Videos',
                isSelected: _kindFilter == MediaKind.video,
                onTap: () => setState(() => _kindFilter = MediaKind.video),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (filtered.isEmpty)
          AppCard(
            child: Text(
              'No media items published in this category yet.',
              style: theme.textTheme.bodyMedium,
            ),
          )
        else
          ResponsiveCardGrid(
            children: filtered.map((media) {
              final isVideo = media.kind == MediaKind.video;
              return AppCard(
                padding: EdgeInsets.zero,
                onTap: () => isVideo
                    ? showVideoEmbedDialog(context, media)
                    : showMediaPreviewDialog(
                        context,
                        media,
                        gallery: filtered,
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CampusNetworkImage(
                          imageUrl: media.thumbnailUrl ?? media.url,
                          height: 172,
                          width: double.infinity,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppRadii.lg - 1),
                          ),
                        ),
                        if (isVideo)
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
                          top: AppSpacing.sm,
                          left: AppSpacing.sm,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background.withValues(
                                alpha: 0.85,
                              ),
                              borderRadius: AppRadii.borderPill,
                            ),
                            child: Text(
                              media.section.label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        media.caption,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
