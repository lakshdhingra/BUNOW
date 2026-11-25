import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/student_portal/presentation/providers/student_portal_providers.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Chronological campus schedule connected to Supabase published events.
class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final eventsAsync = ref.watch(publishedEventsProvider);
    final registeredIds = ref.watch(registeredEventIdsProvider);

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Campus Calendar', style: theme.textTheme.headlineLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Chronological view of upcoming Bennett University events and sessions.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            eventsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: AppLoadingIndicator(message: 'Loading schedule...'),
              ),
              error: (error, _) => AppErrorWidget(
                title: 'Unable to load schedule',
                message: error.toString(),
                onRetry: () => ref.invalidate(publishedEventsProvider),
              ),
              data: (events) {
                if (events.isEmpty) {
                  return AppCard(
                    child: Text(
                      'No upcoming events on the schedule yet.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }

                final sortedEvents = [...events]
                  ..sort((a, b) => a.startTime.compareTo(b.startTime));

                return Column(
                  children: sortedEvents.map((event) {
                    final dayNumber = DateFormat('d').format(event.startTime);
                    final monthLabel = DateFormat('MMM').format(event.startTime);
                    final timeLabel = DateFormat(
                      'EEE · h:mm a',
                    ).format(event.startTime);
                    final isRegistered = registeredIds.contains(event.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: AppCard(
                        onTap: () => context.go(AppRoutes.eventDetail(event.id)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryMuted,
                                borderRadius: AppRadii.borderMd,
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    monthLabel.toUpperCase(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  Text(
                                    dayNumber,
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$timeLabel · ${event.clubName}',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    event.title,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    event.venue,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (isRegistered) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xxs + 2,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppColors.successMuted,
                                  borderRadius: AppRadii.borderPill,
                                ),
                                child: Text(
                                  'Registered',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
