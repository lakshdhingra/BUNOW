import 'package:bennett_campus/features/auth/domain/models/student_user.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';

/// Repository abstraction for event registrations (swappable with Supabase later).
abstract interface class RegistrationRepository {
  Future<List<EventRegistration>> fetchStudentRegistrations(String studentId);

  Future<EventRegistration?> getActiveRegistration({
    required String eventId,
    required String studentId,
  });

  Future<EventRegistration> submitRegistration({
    required CampusEvent event,
    required StudentUser student,
    required Map<String, dynamic> answers,
  });

  Future<EventRegistration> cancelRegistration({
    required String registrationId,
  });
}
