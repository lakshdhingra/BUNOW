import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';
import 'package:bennett_campus/features/student_portal/presentation/providers/student_portal_providers.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/event_card.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Placeholder page for a student's registered events and digital passes.
class MyEventsPage extends ConsumerWidget {
  const MyEventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final registeredIds = ref.watch(registeredEventIdsProvider);
    final myEvents = MockCampusData.events
        .where((event) => registeredIds.contains(event.id))
        .toList();

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Events', style: theme.textTheme.headlineLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Your reserved passes and upcoming campus registrations (mock preview).',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (myEvents.isEmpty)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      size: 32,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No registered events yet',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Browse the Explore tab to reserve your spot for upcoming workshops and fests.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Explore Campus Events',
                      onPressed: () => context.go(AppRoutes.explore),
                    ),
                  ],
                ),
              )
            else
              ResponsiveCardGrid(
                children: myEvents.map((event) {
                  return EventCard(
                    event: event,
                    isRegistered: true,
                    onTap: () => context.go(AppRoutes.eventDetail(event.id)),
                    onActionTap: () => context.go(AppRoutes.eventDetail(event.id)),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
