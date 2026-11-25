import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';

/// Repository contract for fetching campus events and event details/media.
abstract interface class EventRepository {
  Future<List<CampusEvent>> fetchPublishedEvents();

  Future<CampusEvent?> fetchEventById(String eventId);
}
