import 'package:bennett_campus/features/organizer_studio/domain/models/organizer_models.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';

/// Repository contract for Organizer Studio operations (mocked in Stage 4).
abstract interface class OrganizerRepository {
  Future<List<CampusClub>> fetchAuthorizedClubs(List<String> clubIds);

  Future<List<OrganizerEventRecord>> fetchClubEvents(String clubId);

  Future<OrganizerEventRecord> saveEvent(OrganizerEventRecord event);

  Future<OrganizerEventRecord> duplicateEvent(String eventId);

  Future<OrganizerEventRecord> cancelEvent(String eventId);

  Future<List<EventRegistration>> fetchClubRegistrations(String clubId);

  Future<List<OrganizerActivityItem>> fetchRecentActivity(String clubId);

  Future<CampusClub> updateClubProfile(CampusClub club);

  Future<List<ClubRepresentative>> fetchRepresentatives(String clubId);

  Future<ClubRepresentative> addRepresentative({
    required String clubId,
    required String name,
    required String email,
    required String program,
    required OrganizerRole role,
  });

  Future<ClubRepresentative> updateRepresentativeRole({
    required String representativeId,
    required OrganizerRole role,
  });

  Future<void> removeRepresentative(String representativeId);
}
