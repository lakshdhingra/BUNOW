import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/presentation/providers/student_portal_providers.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/category_chip.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/event_card.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/event_detail_dialog.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Explore page listing all mock campus events with live search & category filters.
class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final events = ref.watch(filteredEventsProvider);
    final registeredIds = ref.watch(registeredEventIdsProvider);
    final query = ref.watch(searchQueryProvider);

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Explore Events', style: theme.textTheme.headlineLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Discover every upcoming hackathon, cultural night, workshop, and league across Bennett University.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: EventCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: CategoryChip(
                      label: category.label,
                      isSelected: selectedCategory == category,
                      onTap: () => ref
                          .read(selectedCategoryProvider.notifier)
                          .select(category),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(
                  '${events.length} event${events.length == 1 ? '' : 's'} shown',
                  style: theme.textTheme.labelMedium,
                ),
                if (query.isNotEmpty || selectedCategory != EventCategory.all) ...[
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: () {
                      ref.read(searchQueryProvider.notifier).clear();
                      ref
                          .read(selectedCategoryProvider.notifier)
                          .select(EventCategory.all);
                    },
                    child: const Text('Clear filters'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (events.isEmpty)
              AppCard(
                child: Column(
                  children: [
                    const Icon(
                      Icons.search_off_rounded,
                      size: 32,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No matching campus events',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Try clearing your search or switching event categories.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
            else
              ResponsiveCardGrid(
                children: events.map((event) {
                  final isRegistered = registeredIds.contains(event.id);
                  return EventCard(
                    event: event,
                    isRegistered: isRegistered,
                    onTap: () => showEventPreviewDialog(
                      context: context,
                      event: event,
                      isRegistered: isRegistered,
                      onToggleRegistration: () => ref
                          .read(registeredEventIdsProvider.notifier)
                          .toggle(event.id),
                    ),
                    onActionTap: () => ref
                        .read(registeredEventIdsProvider.notifier)
                        .toggle(event.id),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
