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
import 'package:bennett_campus/features/student_portal/presentation/widgets/featured_event_banner.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/highlight_card.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/section_header.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Student Portal Home Dashboard connected to Supabase events and clubs.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).user;
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final publishedAsync = ref.watch(publishedEventsProvider);
    final filteredAsync = ref.watch(filteredEventsProvider);
    final clubsAsync = ref.watch(activeClubsProvider);
    final registeredIds = ref.watch(registeredEventIdsProvider);
    final isMobile = DeviceScreenType.of(context) == DeviceScreenType.mobile;

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
              'Explore upcoming Bennett University events, active societies, and campus highlights.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            publishedAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: AppLoadingIndicator(
                  message: 'Loading featured and upcoming events...',
                ),
              ),
              error: (error, _) => AppErrorWidget(
                title: 'Unable to load events',
                message: error.toString(),
                onRetry: () => ref.invalidate(publishedEventsProvider),
              ),
              data: (allPublished) {
                if (allPublished.isEmpty) {
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.event_available_outlined,
                          size: 32,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'No published events yet',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Published events added to Supabase will appear here automatically.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                final featuredEvent = allPublished.firstWhere(
                  (event) => event.isFeatured,
                  orElse: () => allPublished.first,
                );

                final upcomingEvents = (filteredAsync.value ?? allPublished)
                    .where((event) => event.id != featuredEvent.id)
                    .take(6)
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FeaturedEventBanner(
                      event: featuredEvent,
                      isRegistered: registeredIds.contains(featuredEvent.id),
                      onRegisterTap: () =>
                          _openRegistrationOrTicket(context, ref, featuredEvent),
                      onDetailsTap: () =>
                          context.go(AppRoutes.eventDetail(featuredEvent.id)),
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
                          ? 'Published across Bennett campus'
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
                                allPublished.length <= 1
                                    ? 'All published events are featured above.'
                                    : 'No upcoming events match your current search or category filter.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            if (allPublished.length > 1)
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
                            onTap: () =>
                                context.go(AppRoutes.eventDetail(event.id)),
                            onActionTap: () =>
                                _openRegistrationOrTicket(context, ref, event),
                          );
                        }).toList(),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            SectionHeader(
              title: 'Popular Clubs',
              subtitle: 'Active Bennett societies and student chapters',
              actionLabel: 'All clubs',
              onActionTap: () => context.go(AppRoutes.clubs),
            ),
            const SizedBox(height: AppSpacing.md),
            clubsAsync.when(
              loading: () => const AppLoadingIndicator(centered: false),
              error: (error, _) => AppErrorWidget(
                title: 'Unable to load clubs',
                message: error.toString(),
                compact: true,
                onRetry: () => ref.invalidate(activeClubsProvider),
              ),
              data: (clubs) {
                if (clubs.isEmpty) {
                  return AppCard(
                    child: Text(
                      'No active clubs found yet.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }
                return ResponsiveCardGrid(
                  children: clubs.take(3).map((club) {
                    return ClubCard(
                      club: club,
                      onTap: () => context.go(AppRoutes.clubProfile(club.id)),
                    );
                  }).toList(),
                );
              },
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

  void _openRegistrationOrTicket(
    BuildContext context,
    WidgetRef ref,
    CampusEvent event,
  ) {
    final activeRegistration = ref.read(
      activeRegistrationForEventProvider(event.id),
    );
    if (activeRegistration != null) {
      context.go(AppRoutes.ticketDetail(activeRegistration.id));
      return;
    }
    if (event.isFull || event.isRegistrationClosed) {
      context.go(AppRoutes.eventDetail(event.id));
      return;
    }
    context.go(AppRoutes.eventRegistration(event.id));
  }
}
