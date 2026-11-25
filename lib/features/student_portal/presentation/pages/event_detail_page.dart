import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/presentation/providers/student_portal_providers.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/event_card.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/media_preview_dialog.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/section_header.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Detailed event view with agenda, speakers, registration card, gallery, and related events.
class EventDetailPage extends ConsumerWidget {
  const EventDetailPage({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = MockCampusData.events
        .where((e) => e.id == eventId)
        .firstOrNull;

    if (event == null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppErrorWidget(
          title: 'Event not found',
          message: 'We could not find an event matching "$eventId".',
          retryLabel: 'Back to Explore',
          onRetry: () => context.go(AppRoutes.explore),
        ),
      );
    }

    final club = MockCampusData.clubs
        .where((c) => c.id == event.clubId)
        .firstOrNull;
    final registeredIds = ref.watch(registeredEventIdsProvider);
    final isRegistered = registeredIds.contains(event.id);
    final isDesktop =
        DeviceScreenType.of(context) == DeviceScreenType.desktop;

    final relatedEvents = MockCampusData.events
        .where(
          (other) =>
              other.id != event.id &&
              (other.category == event.category || other.clubId == event.clubId),
        )
        .take(3)
        .toList();

    final fallbackRelated = relatedEvents.isNotEmpty
        ? relatedEvents
        : MockCampusData.events
              .where((other) => other.id != event.id)
              .take(3)
              .toList();

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BackBar(
              label: 'Back to Explore',
              onPressed: () => context.go(AppRoutes.explore),
            ),
            const SizedBox(height: AppSpacing.md),
            _EventHeroBanner(event: event, isRegistered: isRegistered),
            const SizedBox(height: AppSpacing.xl),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: _EventMainColumn(event: event, club: club),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(
                    flex: 4,
                    child: _RegistrationInfoCard(
                      event: event,
                      club: club,
                      isRegistered: isRegistered,
                      onRegisterTap: () =>
                          _toggleRegistration(context, ref, event),
                    ),
                  ),
                ],
              )
            else ...[
              _RegistrationInfoCard(
                event: event,
                club: club,
                isRegistered: isRegistered,
                onRegisterTap: () => _toggleRegistration(context, ref, event),
              ),
              const SizedBox(height: AppSpacing.xl),
              _EventMainColumn(event: event, club: club),
            ],
            const SizedBox(height: AppSpacing.xxl),
            SectionHeader(
              title: 'Related Events',
              subtitle: 'More campus activities you might enjoy',
              actionLabel: 'Explore all',
              onActionTap: () => context.go(AppRoutes.explore),
            ),
            const SizedBox(height: AppSpacing.md),
            ResponsiveCardGrid(
              children: fallbackRelated.map((item) {
                final itemRegistered = registeredIds.contains(item.id);
                return EventCard(
                  event: item,
                  isRegistered: itemRegistered,
                  onTap: () => context.go(AppRoutes.eventDetail(item.id)),
                  onActionTap: () => ref
                      .read(registeredEventIdsProvider.notifier)
                      .toggle(item.id),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleRegistration(
    BuildContext context,
    WidgetRef ref,
    CampusEvent event,
  ) {
    final wasRegistered = ref
        .read(registeredEventIdsProvider)
        .contains(event.id);
    ref.read(registeredEventIdsProvider.notifier).toggle(event.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasRegistered
              ? 'Removed mock registration for ${event.title}.'
              : 'Mock pass confirmed for ${event.title}.',
        ),
      ),
    );
  }
}

class _BackBar extends StatelessWidget {
  const _BackBar({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back_rounded, size: 18),
      label: Text(label),
    );
  }
}

class _EventHeroBanner extends StatelessWidget {
  const _EventHeroBanner({required this.event, required this.isRegistered});

  final CampusEvent event;
  final bool isRegistered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = DeviceScreenType.of(context) == DeviceScreenType.mobile;
    final dateLabel = DateFormat('EEE, d MMM yyyy · h:mm a').format(
      event.startTime,
    );

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
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.background.withValues(alpha: 0.96),
                      AppColors.background.withValues(alpha: 0.72),
                      AppColors.background.withValues(alpha: 0.35),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isMobile ? 48 : 88),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _DetailChip(
                        label: event.category.label,
                        color: AppColors.primary,
                      ),
                      if (isRegistered)
                        const _DetailChip(
                          label: 'Registered',
                          color: AppColors.success,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    event.title,
                    style: isMobile
                        ? theme.textTheme.headlineMedium
                        : theme.textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _HeroMeta(
                        icon: Icons.groups_outlined,
                        text: event.clubName,
                      ),
                      _HeroMeta(
                        icon: Icons.calendar_today_outlined,
                        text: dateLabel,
                      ),
                      _HeroMeta(
                        icon: Icons.location_on_outlined,
                        text: event.venue,
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
  }
}

class _EventMainColumn extends StatelessWidget {
  const _EventMainColumn({required this.event, required this.club});

  final CampusEvent event;
  final CampusClub? club;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About this Event', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(event.description, style: theme.textTheme.bodyMedium),
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
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (club != null) ...[
          AppCard(
            onTap: () => context.go(AppRoutes.clubProfile(club!.id)),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: AppRadii.borderMd,
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Text(
                    club!.shortCode,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Organized by',
                        style: theme.textTheme.labelSmall,
                      ),
                      Text(club!.name, style: theme.textTheme.titleMedium),
                      Text(
                        club!.tagline,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (event.agenda.isNotEmpty) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Event Agenda', style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.md),
                ...event.agenda.map((slot) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 124,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs + 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: AppRadii.borderSm,
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Text(
                            slot.timeLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(slot.title, style: theme.textTheme.titleSmall),
                              const SizedBox(height: 2),
                              Text(
                                slot.description,
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
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (event.speakers.isNotEmpty) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Speakers & Mentors',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                ResponsiveCardGrid(
                  desktopColumns: 2,
                  tabletColumns: 2,
                  mobileColumns: 1,
                  children: event.speakers.map((speaker) {
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: AppRadii.borderMd,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primaryMuted,
                            child: Text(
                              speaker.initials,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: AppColors.primaryHover,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  speaker.name,
                                  style: theme.textTheme.titleSmall,
                                ),
                                Text(
                                  speaker.role,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.secondary,
                                  ),
                                ),
                                Text(
                                  speaker.organization,
                                  style: theme.textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: AppSpacing.lg),
        ],
        if (event.mediaGallery.isNotEmpty)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Media Gallery', style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Photos from previous editions and club sessions',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                ResponsiveCardGrid(
                  desktopColumns: 2,
                  tabletColumns: 2,
                  mobileColumns: 1,
                  children: event.mediaGallery.map((media) {
                    return InkWell(
                      onTap: () => showMediaPreviewDialog(context, media),
                      borderRadius: AppRadii.borderMd,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CampusNetworkImage(
                            imageUrl: media.url,
                            height: 168,
                            width: double.infinity,
                            borderRadius: AppRadii.borderMd,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            media.caption,
                            style: theme.textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RegistrationInfoCard extends StatelessWidget {
  const _RegistrationInfoCard({
    required this.event,
    required this.club,
    required this.isRegistered,
    required this.onRegisterTap,
  });

  final CampusEvent event;
  final CampusClub? club;
  final bool isRegistered;
  final VoidCallback onRegisterTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startLabel = DateFormat('EEE, d MMM · h:mm a').format(event.startTime);
    final endLabel = DateFormat('EEE, d MMM · h:mm a').format(event.endTime);
    final deadlineLabel = DateFormat('d MMM, h:mm a').format(
      event.registrationDeadline,
    );

    return AppCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Registration Information',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(icon: Icons.play_arrow_rounded, label: 'Starts', value: startLabel),
          _InfoRow(icon: Icons.stop_rounded, label: 'Ends', value: endLabel),
          _InfoRow(icon: Icons.location_on_outlined, label: 'Venue', value: event.venue),
          _InfoRow(icon: Icons.group_outlined, label: 'Participation', value: event.teamSizeLabel),
          _InfoRow(icon: Icons.payments_outlined, label: 'Entry', value: event.feeLabel),
          _InfoRow(icon: Icons.timer_outlined, label: 'Deadline', value: deadlineLabel),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text('Capacity', style: theme.textTheme.labelMedium),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '${event.registeredCount}/${event.capacity} · ${event.spotsRemaining} left',
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: AppRadii.borderPill,
            child: LinearProgressIndicator(
              value: event.fillRatio,
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: isRegistered ? 'Registered · Cancel Mock Pass' : 'Register Now',
            variant: isRegistered
                ? AppButtonVariant.secondary
                : AppButtonVariant.primary,
            leadingIcon: isRegistered
                ? Icons.check_circle_outline_rounded
                : Icons.confirmation_number_outlined,
            fullWidth: true,
            onPressed: onRegisterTap,
          ),
          if (club != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'View ${club!.shortCode} Club Profile',
              variant: AppButtonVariant.outline,
              fullWidth: true,
              onPressed: () => context.go(AppRoutes.clubProfile(club!.id)),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: AppRadii.borderPill,
        border: Border.all(color: color.withValues(alpha: 0.6)),
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

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({required this.icon, required this.text});

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
          ),
        ),
      ],
    );
  }
}
