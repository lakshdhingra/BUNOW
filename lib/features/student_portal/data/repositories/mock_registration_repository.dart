import 'package:bennett_campus/features/auth/domain/models/student_user.dart';
import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';
import 'package:bennett_campus/features/student_portal/domain/repositories/registration_repository.dart';

/// In-memory mock implementation of [RegistrationRepository] for Stage 3.
class MockRegistrationRepository implements RegistrationRepository {
  MockRegistrationRepository()
    : _registrations = List<EventRegistration>.from(
        MockCampusData.initialRegistrations,
      );

  final List<EventRegistration> _registrations;
  int _ticketSequence = 5100;

  @override
  Future<List<EventRegistration>> fetchStudentRegistrations(
    String studentId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final list = _registrations
        .where((reg) => reg.studentId == studentId)
        .toList()
      ..sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
    return List<EventRegistration>.unmodifiable(list);
  }

  @override
  Future<EventRegistration?> getActiveRegistration({
    required String eventId,
    required String studentId,
  }) async {
    for (final reg in _registrations) {
      if (reg.eventId == eventId &&
          reg.studentId == studentId &&
          reg.status == RegistrationStatus.confirmed) {
        return reg;
      }
    }
    return null;
  }

  @override
  Future<EventRegistration> submitRegistration({
    required CampusEvent event,
    required StudentUser student,
    required Map<String, dynamic> answers,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    if (event.isCompleted) {
      throw const RegistrationException(
        'This event has already concluded.',
      );
    }
    if (event.isRegistrationClosed) {
      throw const RegistrationException(
        'Registrations are closed for this event.',
      );
    }
    if (event.isFull) {
      throw const RegistrationException(
        'This event has reached full capacity.',
      );
    }

    final existing = await getActiveRegistration(
      eventId: event.id,
      studentId: student.id,
    );
    if (existing != null) {
      throw const RegistrationException(
        'You already have an active registration for this event.',
      );
    }

    if (event.registrationMode == RegistrationMode.advanced) {
      for (final question in event.registrationQuestions) {
        if (!question.isRequired) continue;
        final value = answers[question.id];
        final isMissing = switch (question.type) {
          QuestionFieldType.checkbox => value != true,
          QuestionFieldType.multipleChoice =>
            value is! List || value.isEmpty,
          QuestionFieldType.fileUpload => value is! UploadedFileMetadata,
          _ => value == null || value.toString().trim().isEmpty,
        };
        if (isMissing) {
          throw RegistrationException(
            'Please complete the required question: "${question.label}".',
          );
        }
      }
    }

    _ticketSequence += 7;
    final clubTag = event.clubName
        .replaceAll(RegExp(r'[^A-Za-z]'), '')
        .toUpperCase();
    final prefix = clubTag.length >= 3 ? clubTag.substring(0, 3) : 'BEN';

    final created = EventRegistration(
      id: 'reg-${DateTime.now().microsecondsSinceEpoch}',
      eventId: event.id,
      studentId: student.id,
      studentName: student.fullName,
      studentEmail: student.email,
      studentProgram: '${student.program} · ${student.batchYear}',
      ticketCode: 'BU-$prefix-$_ticketSequence',
      status: RegistrationStatus.confirmed,
      registeredAt: DateTime.now(),
      answers: Map<String, dynamic>.unmodifiable(answers),
    );

    _registrations.insert(0, created);
    return created;
  }

  @override
  Future<EventRegistration> cancelRegistration({
    required String registrationId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    final index = _registrations.indexWhere((r) => r.id == registrationId);
    if (index < 0) {
      throw const RegistrationException('Registration record not found.');
    }

    final current = _registrations[index];
    if (current.status == RegistrationStatus.completed) {
      throw const RegistrationException(
        'Completed event records cannot be cancelled.',
      );
    }
    if (current.status == RegistrationStatus.cancelled) {
      return current;
    }

    final updated = current.copyWith(
      status: RegistrationStatus.cancelled,
      cancelledAt: DateTime.now(),
    );
    _registrations[index] = updated;
    return updated;
  }
}
