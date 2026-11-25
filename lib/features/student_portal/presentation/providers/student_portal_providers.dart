import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bennett_campus/core/services/supabase_service.dart';
import 'package:bennett_campus/features/auth/presentation/providers/auth_provider.dart';
import 'package:bennett_campus/features/student_portal/data/repositories/mock_club_repository.dart';
import 'package:bennett_campus/features/student_portal/data/repositories/mock_event_repository.dart';
import 'package:bennett_campus/features/student_portal/data/repositories/mock_notification_repository.dart';
import 'package:bennett_campus/features/student_portal/data/repositories/mock_registration_repository.dart';
import 'package:bennett_campus/features/student_portal/data/repositories/supabase_club_repository.dart';
import 'package:bennett_campus/features/student_portal/data/repositories/supabase_event_repository.dart';
import 'package:bennett_campus/features/student_portal/data/repositories/supabase_notification_repository.dart';
import 'package:bennett_campus/features/student_portal/data/repositories/supabase_registration_repository.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';
import 'package:bennett_campus/features/student_portal/domain/repositories/club_repository.dart';
import 'package:bennett_campus/features/student_portal/domain/repositories/event_repository.dart';
import 'package:bennett_campus/features/student_portal/domain/repositories/notification_repository.dart';
import 'package:bennett_campus/features/student_portal/domain/repositories/registration_repository.dart';

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

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  if (SupabaseService.isInitialized) {
    return SupabaseEventRepository(SupabaseService.client);
  }
  return MockEventRepository();
});

final clubRepositoryProvider = Provider<ClubRepository>((ref) {
  if (SupabaseService.isInitialized) {
    return SupabaseClubRepository(SupabaseService.client);
  }
  return MockClubRepository();
});

final registrationRepositoryProvider = Provider<RegistrationRepository>((ref) {
  if (SupabaseService.isInitialized) {
    return SupabaseRegistrationRepository(SupabaseService.client);
  }
  return MockRegistrationRepository();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  if (SupabaseService.isInitialized) {
    return SupabaseNotificationRepository(SupabaseService.client);
  }
  return MockNotificationRepository();
});

final publishedEventsProvider =
    FutureProvider.autoDispose<List<CampusEvent>>((ref) async {
      return ref.watch(eventRepositoryProvider).fetchPublishedEvents();
    });

final eventDetailProvider =
    FutureProvider.autoDispose.family<CampusEvent?, String>((ref, eventId) {
      return ref.watch(eventRepositoryProvider).fetchEventById(eventId);
    });

final activeClubsProvider =
    FutureProvider.autoDispose<List<CampusClub>>((ref) async {
      return ref.watch(clubRepositoryProvider).fetchActiveClubs();
    });

final clubDetailProvider =
    FutureProvider.autoDispose.family<
      ({CampusClub? club, List<CampusEvent> events}),
      String
    >((ref, clubId) async {
      final repo = ref.watch(clubRepositoryProvider);
      final club = await repo.fetchClubById(clubId);
      final events = club == null
          ? const <CampusEvent>[]
          : await repo.fetchEventsForClub(clubId);
      return (club: club, events: events);
    });

class NotificationsController extends AsyncNotifier<List<CampusNotification>> {
  @override
  Future<List<CampusNotification>> build() async {
    final userId = ref.watch(authControllerProvider).user?.id;
    return ref
        .read(notificationRepositoryProvider)
        .fetchNotifications(userId: userId);
  }

  Future<void> markAsRead(String id) async {
    final userId = ref.read(authControllerProvider).user?.id;
    await ref.read(notificationRepositoryProvider).markAsRead(id);
    final next = await ref
        .read(notificationRepositoryProvider)
        .fetchNotifications(userId: userId);
    state = AsyncData(next);
  }

  Future<void> markAsUnread(String id) async {
    final userId = ref.read(authControllerProvider).user?.id;
    await ref.read(notificationRepositoryProvider).markAsUnread(id);
    final next = await ref
        .read(notificationRepositoryProvider)
        .fetchNotifications(userId: userId);
    state = AsyncData(next);
  }

  Future<void> markAllAsRead() async {
    final userId = ref.read(authControllerProvider).user?.id;
    await ref
        .read(notificationRepositoryProvider)
        .markAllAsRead(userId: userId);
    final next = await ref
        .read(notificationRepositoryProvider)
        .fetchNotifications(userId: userId);
    state = AsyncData(next);
  }
}

final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, List<CampusNotification>>(
      NotificationsController.new,
    );

final unreadNotificationsCountProvider = Provider.autoDispose<int>((ref) {
  final list = ref.watch(notificationsControllerProvider).value ?? const [];
  return list.where((n) => n.isUnread).length;
});

/// Manages student registrations via [RegistrationRepository].
class RegistrationsController extends AsyncNotifier<List<EventRegistration>> {
  @override
  Future<List<EventRegistration>> build() async {
    final user = ref.watch(authControllerProvider).user;
    if (user == null) return const [];
    final repository = ref.watch(registrationRepositoryProvider);
    return repository.fetchStudentRegistrations(user.id);
  }

  Future<EventRegistration> registerForEvent({
    required CampusEvent event,
    Map<String, dynamic> answers = const {},
  }) async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) {
      throw const RegistrationException('Please sign in to register.');
    }

    final repository = ref.read(registrationRepositoryProvider);
    final created = await repository.submitRegistration(
      event: event,
      student: user,
      answers: answers,
    );

    final updatedList = await repository.fetchStudentRegistrations(user.id);
    state = AsyncData(updatedList);
    ref.invalidate(publishedEventsProvider);
    ref.invalidate(eventDetailProvider(event.id));
    ref.invalidate(notificationsControllerProvider);
    return created;
  }

  Future<void> cancelRegistration(String registrationId) async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;

    final repository = ref.read(registrationRepositoryProvider);
    await repository.cancelRegistration(registrationId: registrationId);
    final updatedList = await repository.fetchStudentRegistrations(user.id);
    state = AsyncData(updatedList);
    ref.invalidate(publishedEventsProvider);
  }
}

final registrationsControllerProvider =
    AsyncNotifierProvider<RegistrationsController, List<EventRegistration>>(
      RegistrationsController.new,
    );

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

/// Active (confirmed) event IDs for the signed-in student.
final registeredEventIdsProvider = Provider.autoDispose<Set<String>>((ref) {
  final registrations = ref.watch(registrationsControllerProvider).value ?? [];
  return registrations
      .where((r) => r.status == RegistrationStatus.confirmed)
      .map((r) => r.eventId)
      .toSet();
});

/// Finds the active (confirmed) registration for a given [eventId], if any.
final activeRegistrationForEventProvider =
    Provider.autoDispose.family<EventRegistration?, String>((ref, eventId) {
      final registrations =
          ref.watch(registrationsControllerProvider).value ?? [];
      for (final reg in registrations) {
        if (reg.eventId == eventId &&
            reg.status == RegistrationStatus.confirmed) {
          return reg;
        }
      }
      return null;
    });

/// Finds any registration record by its [registrationId].
final registrationByIdProvider =
    Provider.autoDispose.family<EventRegistration?, String>((
      ref,
      registrationId,
    ) {
      final registrations =
          ref.watch(registrationsControllerProvider).value ?? [];
      for (final reg in registrations) {
        if (reg.id == registrationId) return reg;
      }
      return null;
    });

final filteredEventsProvider =
    Provider.autoDispose<AsyncValue<List<CampusEvent>>>((ref) {
      final eventsAsync = ref.watch(publishedEventsProvider);
      final query = ref.watch(searchQueryProvider).trim().toLowerCase();
      final category = ref.watch(selectedCategoryProvider);
      final clubId = ref.watch(selectedClubFilterProvider);
      final dateFilter = ref.watch(selectedDateFilterProvider);
      final statusFilter = ref.watch(registrationStatusFilterProvider);
      final sortOption = ref.watch(eventSortOptionProvider);
      final registeredIds = ref.watch(registeredEventIdsProvider);
      final now = DateTime.now();

      return eventsAsync.whenData((events) {
        final results = events.where((event) {
          if (event.isCompleted) return false;
          if (category != EventCategory.all && event.category != category) {
            return false;
          }
          if (clubId != null && event.clubId != clubId) {
            return false;
          }

          final daysAway = event.startTime.difference(now).inDays;
          final matchesDate = switch (dateFilter) {
            EventDateFilter.all => true,
            EventDateFilter.thisWeek => daysAway >= 0 && daysAway <= 7,
            EventDateFilter.thisMonth => daysAway >= 0 && daysAway <= 30,
            EventDateFilter.upcomingLater => daysAway > 30,
          };
          if (!matchesDate) return false;

          final isRegistered = registeredIds.contains(event.id);
          final matchesStatus = switch (statusFilter) {
            RegistrationStatusFilter.all => true,
            RegistrationStatusFilter.open =>
              !event.isFull && !event.isRegistrationClosed,
            RegistrationStatusFilter.registered => isRegistered,
            RegistrationStatusFilter.fillingFast =>
              event.isFillingFast && !event.isRegistrationClosed,
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
    });
