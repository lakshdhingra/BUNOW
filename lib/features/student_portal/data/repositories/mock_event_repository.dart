import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/repositories/event_repository.dart';

/// Mock implementation of [EventRepository] used in offline widget/unit tests.
class MockEventRepository implements EventRepository {
  @override
  Future<List<CampusEvent>> fetchPublishedEvents() async {
    return MockCampusData.events;
  }

  @override
  Future<CampusEvent?> fetchEventById(String eventId) async {
    for (final event in MockCampusData.events) {
      if (event.id == eventId) return event;
    }
    return null;
  }
}
