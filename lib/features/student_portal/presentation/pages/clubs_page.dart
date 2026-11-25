import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/student_portal/presentation/providers/student_portal_providers.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/category_chip.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/club_card.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Active clubs directory connected to Supabase `clubs`.
class ClubsPage extends ConsumerStatefulWidget {
  const ClubsPage({super.key});

  @override
  ConsumerState<ClubsPage> createState() => _ClubsPageState();
}

class _ClubsPageState extends ConsumerState<ClubsPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = ref.watch(searchQueryProvider).trim().toLowerCase();
    final selectedCategory = ref.watch(clubCategoryFilterProvider);
    final clubsAsync = ref.watch(activeClubsProvider);

    if (_searchController.text != ref.watch(searchQueryProvider)) {
      final current = ref.read(searchQueryProvider);
      _searchController.value = TextEditingValue(
        text: current,
        selection: TextSelection.collapsed(offset: current.length),
      );
    }

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Clubs & Chapters', style: theme.textTheme.headlineLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Explore active student-led technical, cultural, design, and entrepreneurship communities at Bennett University.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: AppSearchBar(
                controller: _searchController,
                hintText: 'Search clubs or societies...',
                onChanged: (value) =>
                    ref.read(searchQueryProvider.notifier).update(value),
                onClear: () => ref.read(searchQueryProvider.notifier).clear(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            clubsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: AppLoadingIndicator(message: 'Loading active clubs...'),
              ),
              error: (error, _) => AppErrorWidget(
                title: 'Unable to load clubs',
                message: error.toString(),
                onRetry: () => ref.invalidate(activeClubsProvider),
              ),
              data: (allClubs) {
                final categories = <String>[
                  'All',
                  ...{for (final club in allClubs) club.category},
                ];

                final effectiveCategory = categories.contains(selectedCategory)
                    ? selectedCategory
                    : 'All';

                final clubs = allClubs.where((club) {
                  if (effectiveCategory != 'All' &&
                      club.category != effectiveCategory) {
                    return false;
                  }
                  if (query.isEmpty) return true;
                  return club.name.toLowerCase().contains(query) ||
                      club.category.toLowerCase().contains(query) ||
                      club.tagline.toLowerCase().contains(query) ||
                      club.about.toLowerCase().contains(query);
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.xs),
                            child: CategoryChip(
                              label: category,
                              isSelected: effectiveCategory == category,
                              onTap: () => ref
                                  .read(clubCategoryFilterProvider.notifier)
                                  .select(category),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (clubs.isEmpty)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.groups_outlined,
                              size: 32,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              allClubs.isEmpty
                                  ? 'No active clubs yet'
                                  : 'No matching clubs found',
                              style: theme.textTheme.titleMedium,
                            ),
                            if (allClubs.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              AppButton(
                                label: 'Show All Clubs',
                                variant: AppButtonVariant.outline,
                                size: AppButtonSize.sm,
                                onPressed: () {
                                  ref.read(searchQueryProvider.notifier).clear();
                                  ref
                                      .read(clubCategoryFilterProvider.notifier)
                                      .select('All');
                                },
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      ResponsiveCardGrid(
                        children: clubs.map((club) {
                          return ClubCard(
                            club: club,
                            onTap: () =>
                                context.go(AppRoutes.clubProfile(club.id)),
                          );
                        }).toList(),
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
}
