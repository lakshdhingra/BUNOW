import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/organizer_studio/domain/models/attendance_models.dart';
import 'package:bennett_campus/features/organizer_studio/domain/models/organizer_models.dart';
import 'package:bennett_campus/features/organizer_studio/presentation/providers/organizer_providers.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Organizer Studio productivity dashboard with KPIs, analytics, and activity.
class OrganizerDashboardPage extends ConsumerWidget {
  const OrganizerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeClub = ref.watch(activeOrganizerClubProvider);
    final eventsAsync = ref.watch(organizerEventsControllerProvider);
    final registrationsAsync = ref.watch(organizerClubRegistrationsProvider);
    final activityAsync = ref.watch(organizerRecentActivityProvider);
    final trendsAsync = ref.watch(organizerRegistrationTrendsProvider);
    final participationAsync = ref.watch(
      organizerParticipationSummariesProvider,
    );
    final isDesktop = DeviceScreenType.of(context) == DeviceScreenType.desktop;

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${activeClub?.name ?? 'Club'} Dashboard',
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Overview of published events, registrations, and club performance.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            eventsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: AppLoadingIndicator(message: 'Loading club metrics...'),
              ),
              error: (error, _) => AppErrorWidget(
                message: error.toString(),
                onRetry: () =>
                    ref.invalidate(organizerEventsControllerProvider),
              ),
              data: (events) {
                final publishedEvents = events
                    .where((e) => e.status == OrganizerEventStatus.published)
                    .toList();
                final upcomingEvents = publishedEvents
                    .where((e) => e.startTime.isAfter(DateTime(2026, 11, 25)))
                    .toList()
                  ..sort((a, b) => a.startTime.compareTo(b.startTime));
                final totalEventRegistrations = events.fold<int>(
                  0,
                  (sum, e) => sum + e.registeredCount,
                );
                final trackedResponses =
                    registrationsAsync.value?.length ?? 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveCardGrid(
                      desktopColumns: 4,
                      tabletColumns: 2,
                      mobileColumns: 1,
                      children: [
                        _KpiCard(
                          label: 'Published Events',
                          value: '${publishedEvents.length}',
                          helper:
                              '${events.where((e) => e.status == OrganizerEventStatus.draft).length} drafts in progress',
                          icon: Icons.campaign_outlined,
                          accent: AppColors.primary,
                        ),
                        _KpiCard(
                          label: 'Total Registrations',
                          value: '$totalEventRegistrations',
                          helper: '$trackedResponses detailed records synced',
                          icon: Icons.how_to_reg_outlined,
                          accent: AppColors.secondary,
                        ),
                        _KpiCard(
                          label: 'Upcoming Events',
                          value: '${upcomingEvents.length}',
                          helper: upcomingEvents.isNotEmpty
                              ? 'Next: ${DateFormat('d MMM').format(upcomingEvents.first.startTime)}'
                              : 'No upcoming scheduled',
                          icon: Icons.calendar_today_outlined,
                          accent: AppColors.success,
                        ),
                        _KpiCard(
                          label: 'Avg. Fill Rate',
                          value: _avgFillLabel(publishedEvents),
                          helper: 'Across active published events',
                          icon: Icons.trending_up_rounded,
                          accent: AppColors.primaryHover,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: _RegistrationAnalyticsCard(
                              events: publishedEvents,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            flex: 5,
                            child: _RecentActivityCard(
                              activityAsync: activityAsync,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _RegistrationAnalyticsCard(events: publishedEvents),
                      const SizedBox(height: AppSpacing.lg),
                      _RecentActivityCard(activityAsync: activityAsync),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _RegistrationTrendsCard(
                              trendsAsync: trendsAsync,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            flex: 7,
                            child: _ParticipationSummariesCard(
                              summariesAsync: participationAsync,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _RegistrationTrendsCard(trendsAsync: trendsAsync),
                      const SizedBox(height: AppSpacing.lg),
                      _ParticipationSummariesCard(
                        summariesAsync: participationAsync,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Upcoming Published Events',
                                  style: theme.textTheme.headlineSmall,
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.go(AppRoutes.organizerEvents),
                                child: const Text('Manage all'),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (upcomingEvents.isEmpty)
                            Text(
                              'No upcoming published events yet. Launch the Event Wizard to create one.',
                              style: theme.textTheme.bodyMedium,
                            )
                          else
                            ...upcomingEvents.map((event) {
                              return Container(
                                margin: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: AppRadii.borderMd,
                                  border: Border.all(
                                    color: AppColors.borderSubtle,
                                  ),
                                ),
                                child: Wrap(
                                  spacing: AppSpacing.md,
                                  runSpacing: AppSpacing.sm,
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 460,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event.title,
                                            style: theme.textTheme.titleSmall,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${DateFormat('EEE, d MMM · h:mm a').format(event.startTime)} · ${event.venue}',
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Wrap(
                                      spacing: AppSpacing.xs,
                                      runSpacing: AppSpacing.xs,
                                      children: [
                                        AppButton(
                                          label: 'Edit',
                                          variant: AppButtonVariant.outline,
                                          size: AppButtonSize.sm,
                                          onPressed: () => context.go(
                                            AppRoutes.organizerEditEvent(
                                              event.id,
                                            ),
                                          ),
                                        ),
                                        AppButton(
                                          label:
                                              '${event.registeredCount}/${event.capacity} Regs',
                                          variant: AppButtonVariant.secondary,
                                          size: AppButtonSize.sm,
                                          onPressed: () {
                                            ref
                                                .read(
                                                  registrationEventFilterProvider
                                                      .notifier,
                                                )
                                                .select(event.id);
                                            context.go(
                                              AppRoutes.organizerRegistrations,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static String _avgFillLabel(List<OrganizerEventRecord> events) {
    if (events.isEmpty) return '0%';
    final avg =
        events.fold<double>(0, (sum, e) => sum + e.fillRatio) / events.length;
    return '${(avg * 100).round()}%';
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.helper,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final String helper;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: AppRadii.borderSm,
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: theme.textTheme.headlineLarge),
          const SizedBox(height: 2),
          Text(
            helper,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _RegistrationAnalyticsCard extends StatelessWidget {
  const _RegistrationAnalyticsCard({required this.events});

  final List<OrganizerEventRecord> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Registration Analytics', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 2),
          Text(
            'Capacity utilization across published club events',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (events.isEmpty)
            Text(
              'Publish an event to view capacity analytics.',
              style: theme.textTheme.bodyMedium,
            )
          else
            ...events.map((event) {
              final percent = (event.fillRatio * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: theme.textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '${event.registeredCount}/${event.capacity} ($percent%)',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.secondary,
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percent >= 85 ? AppColors.secondary : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.activityAsync});

  final AsyncValue<List<OrganizerActivityItem>> activityAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          activityAsync.when(
            loading: () => const AppLoadingIndicator(centered: false),
            error: (e, _) => Text(e.toString(), style: theme.textTheme.bodySmall),
            data: (items) {
              return Column(
                children: items.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.sm + 2),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadii.borderMd,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: theme.textTheme.titleSmall),
                              Text(
                                item.subtitle,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(item.timeAgo, style: theme.textTheme.labelSmall),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}


class _RegistrationTrendsCard extends StatelessWidget {
  const _RegistrationTrendsCard({required this.trendsAsync});

  final AsyncValue<List<RegistrationTrendPoint>> trendsAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Registration Trends', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 2),
          Text(
            'Daily registrations over the past 7 days',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          trendsAsync.when(
            loading: () => const AppLoadingIndicator(centered: false),
            error: (e, _) => Text(e.toString(), style: theme.textTheme.bodySmall),
            data: (points) {
              if (points.isEmpty) {
                return Text(
                  'No trend data available yet.',
                  style: theme.textTheme.bodyMedium,
                );
              }
              final maxCount = points
                  .map((p) => p.count)
                  .reduce((a, b) => a > b ? a : b)
                  .clamp(1, 99999);

              return SizedBox(
                height: 164,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: points.map((point) {
                    final ratio = point.count / maxCount;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${point.count}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 100 * ratio + 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(AppRadii.xs),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              point.dayLabel,
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ParticipationSummariesCard extends StatelessWidget {
  const _ParticipationSummariesCard({required this.summariesAsync});

  final AsyncValue<List<EventParticipationSummary>> summariesAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Participation Summaries',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Registrations, attendance numbers, and check-in conversion rates',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          summariesAsync.when(
            loading: () => const AppLoadingIndicator(centered: false),
            error: (e, _) => Text(e.toString(), style: theme.textTheme.bodySmall),
            data: (summaries) {
              if (summaries.isEmpty) {
                return Text(
                  'No events found for participation summary.',
                  style: theme.textTheme.bodyMedium,
                );
              }
              return Column(
                children: summaries.map((item) {
                  final attendancePercent = (item.attendanceRate * 100).round();
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.sm + 2),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadii.borderMd,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.xs,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.eventTitle,
                                style: theme.textTheme.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.registrationMode.label,
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                        Wrap(
                          spacing: AppSpacing.md,
                          children: [
                            _MetricBadge(
                              label: 'Reg',
                              value: '${item.registeredCount}/${item.capacity}',
                            ),
                            _MetricBadge(
                              label: 'Attended',
                              value: '${item.checkedInCount} ($attendancePercent%)',
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        Text(
          value,
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}
