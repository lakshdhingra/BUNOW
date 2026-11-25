import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;

  void clear() => state = '';
}

class SelectedCategoryNotifier extends Notifier<EventCategory> {
  @override
  EventCategory build() => EventCategory.all;

  void select(EventCategory category) => state = category;
}

class SelectedClubFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? clubId) => state = clubId;
}

class SelectedDateFilterNotifier extends Notifier<EventDateFilter> {
  @override
  EventDateFilter build() => EventDateFilter.all;

  void select(EventDateFilter filter) => state = filter;
}

class RegistrationStatusFilterNotifier
    extends Notifier<RegistrationStatusFilter> {
  @override
  RegistrationStatusFilter build() => RegistrationStatusFilter.all;

  void select(RegistrationStatusFilter filter) => state = filter;
}

class EventSortOptionNotifier extends Notifier<EventSortOption> {
  @override
  EventSortOption build() => EventSortOption.upcoming;

  void select(EventSortOption sortOption) => state = sortOption;
}

class ClubCategoryFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void select(String category) => state = category;
}

class RegisteredEventIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return MockCampusData.events
        .where((e) => e.isRegistered)
        .map((e) => e.id)
        .toSet();
  }

  void toggle(String eventId) {
    final next = Set<String>.from(state);
    if (next.contains(eventId)) {
      next.remove(eventId);
    } else {
      next.add(eventId);
    }
    state = next;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, EventCategory>(
      SelectedCategoryNotifier.new,
    );

final selectedClubFilterProvider =
    NotifierProvider<SelectedClubFilterNotifier, String?>(
      SelectedClubFilterNotifier.new,
    );

final selectedDateFilterProvider =
    NotifierProvider<SelectedDateFilterNotifier, EventDateFilter>(
      SelectedDateFilterNotifier.new,
    );

final registrationStatusFilterProvider =
    NotifierProvider<
      RegistrationStatusFilterNotifier,
      RegistrationStatusFilter
    >(RegistrationStatusFilterNotifier.new);

final eventSortOptionProvider =
    NotifierProvider<EventSortOptionNotifier, EventSortOption>(
      EventSortOptionNotifier.new,
    );

final clubCategoryFilterProvider =
    NotifierProvider<ClubCategoryFilterNotifier, String>(
      ClubCategoryFilterNotifier.new,
    );

final registeredEventIdsProvider =
    NotifierProvider<RegisteredEventIdsNotifier, Set<String>>(
      RegisteredEventIdsNotifier.new,
    );

/// Reference date anchored to the mock dataset timeline for predictable filtering.
final DateTime _mockReferenceDate = DateTime(2026, 11, 26);

final filteredEventsProvider = Provider<List<CampusEvent>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final category = ref.watch(selectedCategoryProvider);
  final clubId = ref.watch(selectedClubFilterProvider);
  final dateFilter = ref.watch(selectedDateFilterProvider);
  final statusFilter = ref.watch(registrationStatusFilterProvider);
  final sortOption = ref.watch(eventSortOptionProvider);
  final registeredIds = ref.watch(registeredEventIdsProvider);

  final results = MockCampusData.events.where((event) {
    if (category != EventCategory.all && event.category != category) {
      return false;
    }
    if (clubId != null && event.clubId != clubId) {
      return false;
    }

    final daysAway = event.startTime.difference(_mockReferenceDate).inDays;
    final matchesDate = switch (dateFilter) {
      EventDateFilter.all => true,
      EventDateFilter.thisWeek => daysAway <= 7,
      EventDateFilter.thisMonth => daysAway <= 30,
      EventDateFilter.upcomingLater => daysAway > 30,
    };
    if (!matchesDate) return false;

    final isRegistered = registeredIds.contains(event.id);
    final matchesStatus = switch (statusFilter) {
      RegistrationStatusFilter.all => true,
      RegistrationStatusFilter.open => event.spotsRemaining > 0,
      RegistrationStatusFilter.registered => isRegistered,
      RegistrationStatusFilter.fillingFast => event.isFillingFast,
    };
    if (!matchesStatus) return false;

    if (query.isEmpty) return true;
    return event.title.toLowerCase().contains(query) ||
        event.clubName.toLowerCase().contains(query) ||
        event.venue.toLowerCase().contains(query) ||
        event.category.label.toLowerCase().contains(query) ||
        event.tags.any((tag) => tag.toLowerCase().contains(query));
  }).toList();

  switch (sortOption) {
    case EventSortOption.upcoming:
      results.sort((a, b) => a.startTime.compareTo(b.startTime));
    case EventSortOption.recentlyPublished:
      results.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  }

  return results;
});
