import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/repositories/club_repository.dart';

/// Mock implementation of [ClubRepository] used in offline widget/unit tests.
class MockClubRepository implements ClubRepository {
  @override
  Future<List<CampusClub>> fetchActiveClubs() async {
    return MockCampusData.clubs;
  }

  @override
  Future<CampusClub?> fetchClubById(String clubId) async {
    for (final club in MockCampusData.clubs) {
      if (club.id == clubId) return club;
    }
    return null;
  }

  @override
  Future<List<CampusEvent>> fetchEventsForClub(String clubId) async {
    return MockCampusData.events.where((e) => e.clubId == clubId).toList();
  }
}
