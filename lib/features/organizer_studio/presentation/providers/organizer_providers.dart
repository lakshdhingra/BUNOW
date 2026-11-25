import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bennett_campus/features/auth/presentation/providers/auth_provider.dart';
import 'package:bennett_campus/features/organizer_studio/data/repositories/mock_organizer_repository.dart';
import 'package:bennett_campus/features/organizer_studio/domain/models/organizer_models.dart';
import 'package:bennett_campus/features/organizer_studio/domain/repositories/organizer_repository.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';

final organizerRepositoryProvider = Provider<OrganizerRepository>((ref) {
  return MockOrganizerRepository();
});

class AuthorizedClubsNotifier extends AsyncNotifier<List<CampusClub>> {
  @override
  Future<List<CampusClub>> build() async {
    final user = ref.watch(authControllerProvider).user;
    if (user == null || user.authorizedClubIds.isEmpty) return const [];
    return ref
        .read(organizerRepositoryProvider)
        .fetchAuthorizedClubs(user.authorizedClubIds);
  }

  Future<void> updateClub(CampusClub updated) async {
    final saved = await ref
        .read(organizerRepositoryProvider)
        .updateClubProfile(updated);
    final current = state.value ?? const <CampusClub>[];
    state = AsyncData([
      for (final club in current)
        if (club.id == saved.id) saved else club,
    ]);
  }
}

final authorizedClubsProvider =
    AsyncNotifierProvider<AuthorizedClubsNotifier, List<CampusClub>>(
      AuthorizedClubsNotifier.new,
    );

class SelectedOrganizerClubIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    final user = ref.watch(authControllerProvider).user;
    if (user == null || user.authorizedClubIds.isEmpty) return null;
    return user.authorizedClubIds.first;
  }

  void select(String clubId) => state = clubId;
}

final selectedOrganizerClubIdProvider =
    NotifierProvider<SelectedOrganizerClubIdNotifier, String?>(
      SelectedOrganizerClubIdNotifier.new,
    );

final activeOrganizerClubProvider = Provider.autoDispose<CampusClub?>((ref) {
  final clubs = ref.watch(authorizedClubsProvider).value ?? const [];
  final selectedId = ref.watch(selectedOrganizerClubIdProvider);
  if (clubs.isEmpty) return null;
  for (final club in clubs) {
    if (club.id == selectedId) return club;
  }
  return clubs.first;
});

class OrganizerEventsController
    extends AsyncNotifier<List<OrganizerEventRecord>> {
  @override
  Future<List<OrganizerEventRecord>> build() async {
    final clubId = ref.watch(selectedOrganizerClubIdProvider);
    if (clubId == null) return const [];
    return ref.read(organizerRepositoryProvider).fetchClubEvents(clubId);
  }

  Future<OrganizerEventRecord> saveEvent(OrganizerEventRecord event) async {
    final saved = await ref.read(organizerRepositoryProvider).saveEvent(event);
    final clubId = ref.read(selectedOrganizerClubIdProvider);
    if (clubId != null) {
      final list = await ref
          .read(organizerRepositoryProvider)
          .fetchClubEvents(clubId);
      state = AsyncData(list);
    }
    return saved;
  }

  Future<OrganizerEventRecord> duplicateEvent(String eventId) async {
    final copy = await ref
        .read(organizerRepositoryProvider)
        .duplicateEvent(eventId);
    final clubId = ref.read(selectedOrganizerClubIdProvider);
    if (clubId != null) {
      final list = await ref
          .read(organizerRepositoryProvider)
          .fetchClubEvents(clubId);
      state = AsyncData(list);
    }
    return copy;
  }

  Future<void> cancelEvent(String eventId) async {
    await ref.read(organizerRepositoryProvider).cancelEvent(eventId);
    final clubId = ref.read(selectedOrganizerClubIdProvider);
    if (clubId != null) {
      final list = await ref
          .read(organizerRepositoryProvider)
          .fetchClubEvents(clubId);
      state = AsyncData(list);
    }
  }
}

final organizerEventsControllerProvider =
    AsyncNotifierProvider<OrganizerEventsController, List<OrganizerEventRecord>>(
      OrganizerEventsController.new,
    );

final organizerClubRegistrationsProvider =
    FutureProvider.autoDispose<List<EventRegistration>>((ref) async {
      final clubId = ref.watch(selectedOrganizerClubIdProvider);
      if (clubId == null) return const [];
      return ref
          .read(organizerRepositoryProvider)
          .fetchClubRegistrations(clubId);
    });

final organizerRecentActivityProvider =
    FutureProvider.autoDispose<List<OrganizerActivityItem>>((ref) async {
      final clubId = ref.watch(selectedOrganizerClubIdProvider);
      if (clubId == null) return const [];
      return ref.read(organizerRepositoryProvider).fetchRecentActivity(clubId);
    });

class ClubRepresentativesController
    extends AsyncNotifier<List<ClubRepresentative>> {
  @override
  Future<List<ClubRepresentative>> build() async {
    final clubId = ref.watch(selectedOrganizerClubIdProvider);
    if (clubId == null) return const [];
    return ref.read(organizerRepositoryProvider).fetchRepresentatives(clubId);
  }

  Future<void> addRepresentative({
    required String name,
    required String email,
    required String program,
    required OrganizerRole role,
  }) async {
    final clubId = ref.read(selectedOrganizerClubIdProvider);
    if (clubId == null) return;
    await ref.read(organizerRepositoryProvider).addRepresentative(
      clubId: clubId,
      name: name,
      email: email,
      program: program,
      role: role,
    );
    final updated = await ref
        .read(organizerRepositoryProvider)
        .fetchRepresentatives(clubId);
    state = AsyncData(updated);
  }

  Future<void> updateRole({
    required String representativeId,
    required OrganizerRole role,
  }) async {
    final clubId = ref.read(selectedOrganizerClubIdProvider);
    if (clubId == null) return;
    await ref.read(organizerRepositoryProvider).updateRepresentativeRole(
      representativeId: representativeId,
      role: role,
    );
    final updated = await ref
        .read(organizerRepositoryProvider)
        .fetchRepresentatives(clubId);
    state = AsyncData(updated);
  }

  Future<void> removeRepresentative(String representativeId) async {
    final clubId = ref.read(selectedOrganizerClubIdProvider);
    if (clubId == null) return;
    await ref
        .read(organizerRepositoryProvider)
        .removeRepresentative(representativeId);
    final updated = await ref
        .read(organizerRepositoryProvider)
        .fetchRepresentatives(clubId);
    state = AsyncData(updated);
  }
}

final clubRepresentativesControllerProvider =
    AsyncNotifierProvider<
      ClubRepresentativesController,
      List<ClubRepresentative>
    >(ClubRepresentativesController.new);

class RegistrationEventFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? eventId) => state = eventId;
}

final registrationEventFilterProvider =
    NotifierProvider<RegistrationEventFilterNotifier, String?>(
      RegistrationEventFilterNotifier.new,
    );
