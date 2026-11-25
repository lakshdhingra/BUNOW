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

final registeredEventIdsProvider =
    NotifierProvider<RegisteredEventIdsNotifier, Set<String>>(
      RegisteredEventIdsNotifier.new,
    );

final filteredEventsProvider = Provider<List<CampusEvent>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final category = ref.watch(selectedCategoryProvider);

  return MockCampusData.events.where((event) {
    final matchesCategory =
        category == EventCategory.all || event.category == category;
    if (!matchesCategory) return false;
    if (query.isEmpty) return true;

    return event.title.toLowerCase().contains(query) ||
        event.clubName.toLowerCase().contains(query) ||
        event.venue.toLowerCase().contains(query) ||
        event.category.label.toLowerCase().contains(query);
  }).toList();
});
