import 'package:bennett_campus/features/organizer_studio/domain/models/attendance_models.dart';
import 'package:bennett_campus/features/organizer_studio/domain/models/organizer_models.dart';

/// Repository contract for organizer check-in and analytics (mocked in Stage 5).
abstract interface class AttendanceRepository {
  Future<List<AttendanceCheckInRecord>> fetchEventAttendance(String eventId);

  Future<AttendanceCheckInRecord?> fetchStudentAttendanceForEvent({
    required String eventId,
    required String studentEmail,
  });

  Future<AttendanceCheckInRecord> checkInByTicketCode({
    required String eventId,
    required String ticketCode,
    required String checkedInBy,
  });

  Future<AttendanceCheckInRecord> checkInManually({
    required String eventId,
    required String registrationId,
    required String checkedInBy,
  });

  Future<List<RegistrationTrendPoint>> fetchRegistrationTrends(String clubId);

  Future<List<EventParticipationSummary>> fetchParticipationSummaries({
    required String clubId,
    required List<OrganizerEventRecord> events,
  });
}
