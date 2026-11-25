import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/auth/presentation/providers/auth_provider.dart';
import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/presentation/providers/student_portal_providers.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/category_chip.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/club_card.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/event_card.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/event_detail_dialog.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/featured_event_banner.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/highlight_card.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/section_header.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Student Portal Home Dashboard (Stage 1 mock data).
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).user;
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final filteredEvents = ref.watch(filteredEventsProvider);
    final registeredIds = ref.watch(registeredEventIdsProvider);
    final isMobile = DeviceScreenType.of(context) == DeviceScreenType.mobile;

    final featuredEvent = MockCampusData.events.firstWhere(
      (event) => event.isFeatured,
      orElse: () => MockCampusData.events.first,
    );

    final upcomingEvents = filteredEvents
        .where((event) => event.id != featuredEvent.id)
        .take(6)
        .toList();

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${user?.firstName ?? 'Student'}',
              style: isMobile
                  ? theme.textTheme.headlineLarge
                  : theme.textTheme.displaySmall,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Autumn Semester · Explore upcoming Bennett University events, societies, and campus highlights.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            FeaturedEventBanner(
              event: featuredEvent,
              isRegistered: registeredIds.contains(featuredEvent.id),
              onRegisterTap: () =>
                  _toggleEventRegistration(context, ref, featuredEvent),
              onDetailsTap: () => showEventPreviewDialog(
                context: context,
                event: featuredEvent,
                isRegistered: registeredIds.contains(featuredEvent.id),
                onToggleRegistration: () =>
                    _toggleEventRegistration(context, ref, featuredEvent),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(
              title: 'Event Categories',
              subtitle: 'Filter upcoming campus activities by interest',
            ),
            const SizedBox(height: AppSpacing.md),
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
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(
              title: 'Upcoming Events',
              subtitle: selectedCategory == EventCategory.all
                  ? 'Happening across Bennett campus this week'
                  : 'Filtered by ${selectedCategory.label}',
              actionLabel: 'Explore all',
              onActionTap: () => context.go(AppRoutes.explore),
            ),
            const SizedBox(height: AppSpacing.md),
            if (upcomingEvents.isEmpty)
              AppCard(
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_busy_outlined,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'No upcoming events match your current search or category filter.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    AppButton(
                      label: 'Reset',
                      variant: AppButtonVariant.outline,
                      size: AppButtonSize.sm,
                      onPressed: () {
                        ref.read(searchQueryProvider.notifier).clear();
                        ref
                            .read(selectedCategoryProvider.notifier)
                            .select(EventCategory.all);
                      },
                    ),
                  ],
                ),
              )
            else
              ResponsiveCardGrid(
                children: upcomingEvents.map((event) {
                  final isRegistered = registeredIds.contains(event.id);
                  return EventCard(
                    event: event,
                    isRegistered: isRegistered,
                    onTap: () => showEventPreviewDialog(
                      context: context,
                      event: event,
                      isRegistered: isRegistered,
                      onToggleRegistration: () =>
                          _toggleEventRegistration(context, ref, event),
                    ),
                    onActionTap: () =>
                        _toggleEventRegistration(context, ref, event),
                  );
                }).toList(),
              ),
            const SizedBox(height: AppSpacing.xxl),
            SectionHeader(
              title: 'Popular Clubs',
              subtitle: 'Verified Bennett societies and student chapters',
              actionLabel: 'All clubs',
              onActionTap: () => context.go(AppRoutes.clubs),
            ),
            const SizedBox(height: AppSpacing.md),
            ResponsiveCardGrid(
              children: MockCampusData.clubs.take(3).map((club) {
                return ClubCard(
                  club: club,
                  onTap: () => context.go(AppRoutes.clubs),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SectionHeader(
              title: 'Campus Highlights',
              subtitle: 'Moments from recent fests, hackathons, and showcases',
              actionLabel: 'View gallery',
              onActionTap: () => context.go(AppRoutes.highlights),
            ),
            const SizedBox(height: AppSpacing.md),
            ResponsiveCardGrid(
              children: MockCampusData.highlights.map((highlight) {
                return HighlightCard(
                  highlight: highlight,
                  onTap: () => context.go(AppRoutes.highlights),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _toggleEventRegistration(
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
              ? 'Removed mock pass for ${event.title}.'
              : 'Mock pass reserved for ${event.title}.',
        ),
      ),
    );
  }
}
