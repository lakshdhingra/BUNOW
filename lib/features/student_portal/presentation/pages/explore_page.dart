import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/presentation/providers/student_portal_providers.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/category_chip.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/event_card.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Full Event Discovery page with search, multi-axis filters, and sorting.
class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  late final TextEditingController _localSearchController;

  @override
  void initState() {
    super.initState();
    _localSearchController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
  }

  @override
  void dispose() {
    _localSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedClubId = ref.watch(selectedClubFilterProvider);
    final selectedDateFilter = ref.watch(selectedDateFilterProvider);
    final selectedStatusFilter = ref.watch(registrationStatusFilterProvider);
    final sortOption = ref.watch(eventSortOptionProvider);
    final events = ref.watch(filteredEventsProvider);
    final registeredIds = ref.watch(registeredEventIdsProvider);
    final query = ref.watch(searchQueryProvider);

    if (_localSearchController.text != query) {
      _localSearchController.value = TextEditingValue(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }

    final hasActiveFilters =
        query.isNotEmpty ||
        selectedCategory != EventCategory.all ||
        selectedClubId != null ||
        selectedDateFilter != EventDateFilter.all ||
        selectedStatusFilter != RegistrationStatusFilter.all ||
        sortOption != EventSortOption.upcoming;

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Explore Events', style: theme.textTheme.headlineLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Search, filter by club, date, or registration status, and discover upcoming campus events.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: AppSearchBar(
                controller: _localSearchController,
                hintText: 'Search by title, club, venue, or tag...',
                onChanged: (value) =>
                    ref.read(searchQueryProvider.notifier).update(value),
                onClear: () => ref.read(searchQueryProvider.notifier).clear(),
              ),
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
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _FilterDropdown<String?>(
                    label: 'Club',
                    value: selectedClubId,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Clubs'),
                      ),
                      ...MockCampusData.clubs.map(
                        (club) => DropdownMenuItem<String?>(
                          value: club.id,
                          child: Text(club.name),
                        ),
                      ),
                    ],
                    onChanged: (value) => ref
                        .read(selectedClubFilterProvider.notifier)
                        .select(value),
                  ),
                  _FilterDropdown<EventDateFilter>(
                    label: 'Date',
                    value: selectedDateFilter,
                    items: EventDateFilter.values
                        .map(
                          (f) => DropdownMenuItem(
                            value: f,
                            child: Text(f.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(selectedDateFilterProvider.notifier)
                            .select(value);
                      }
                    },
                  ),
                  _FilterDropdown<RegistrationStatusFilter>(
                    label: 'Registration',
                    value: selectedStatusFilter,
                    items: RegistrationStatusFilter.values
                        .map(
                          (f) => DropdownMenuItem(
                            value: f,
                            child: Text(f.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(registrationStatusFilterProvider.notifier)
                            .select(value);
                      }
                    },
                  ),
                  _FilterDropdown<EventSortOption>(
                    label: 'Sort By',
                    value: sortOption,
                    items: EventSortOption.values
                        .map(
                          (option) => DropdownMenuItem(
                            value: option,
                            child: Text(option.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(eventSortOptionProvider.notifier)
                            .select(value);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(
                  '${events.length} event${events.length == 1 ? '' : 's'} found',
                  style: theme.textTheme.labelMedium,
                ),
                if (hasActiveFilters) ...[
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: _resetAllFilters,
                    child: const Text('Reset filters'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (events.isEmpty)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      'Try clearing your search query or adjusting the club, date, and registration filters.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Reset All Filters',
                      variant: AppButtonVariant.outline,
                      size: AppButtonSize.sm,
                      onPressed: _resetAllFilters,
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
                    onTap: () => context.go(AppRoutes.eventDetail(event.id)),
                    onActionTap: () {
                      ref
                          .read(registeredEventIdsProvider.notifier)
                          .toggle(event.id);
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _resetAllFilters() {
    ref.read(searchQueryProvider.notifier).clear();
    ref.read(selectedCategoryProvider.notifier).select(EventCategory.all);
    ref.read(selectedClubFilterProvider.notifier).select(null);
    ref.read(selectedDateFilterProvider.notifier).select(EventDateFilter.all);
    ref
        .read(registrationStatusFilterProvider.notifier)
        .select(RegistrationStatusFilter.all);
    ref.read(eventSortOptionProvider.notifier).select(EventSortOption.upcoming);
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 230),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        dropdownColor: AppColors.surfaceElevated,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.background,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 2,
            vertical: AppSpacing.sm + 2,
          ),
          border: const OutlineInputBorder(
            borderRadius: AppRadii.borderMd,
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: AppRadii.borderMd,
            borderSide: BorderSide(color: AppColors.border),
          ),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}
