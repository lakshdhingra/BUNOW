import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';

/// Repository contract for Bennett University clubs and club profiles.
abstract interface class ClubRepository {
  Future<List<CampusClub>> fetchActiveClubs();

  Future<CampusClub?> fetchClubById(String clubId);

  Future<List<CampusEvent>> fetchEventsForClub(String clubId);
}
