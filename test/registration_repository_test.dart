import 'package:flutter_test/flutter_test.dart';
import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';
import 'package:bennett_campus/features/student_portal/data/repositories/mock_registration_repository.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';

void main() {
  group('MockRegistrationRepository', () {
    test('prevents duplicate registrations for an already registered event', () async {
      final repo = MockRegistrationRepository();
      final hackaccino = MockCampusData.events.firstWhere(
        (e) => e.id == 'evt-hackaccino',
      );

      expect(
        () => repo.submitRegistration(
          event: hackaccino,
          student: MockCampusData.currentStudent,
          answers: const {},
        ),
        throwsA(isA<RegistrationException>()),
      );
    });

    test('blocks full events and closed registrations', () async {
      final repo = MockRegistrationRepository();
      final fullEvent = MockCampusData.events.firstWhere(
        (e) => e.id == 'evt-cloud-bootcamp',
      );
      final closedEvent = MockCampusData.events.firstWhere(
        (e) => e.id == 'evt-robotics-closed',
      );

      expect(
        () => repo.submitRegistration(
          event: fullEvent,
          student: MockCampusData.currentStudent,
          answers: const {},
        ),
        throwsA(isA<RegistrationException>()),
      );
      expect(
        () => repo.submitRegistration(
          event: closedEvent,
          student: MockCampusData.currentStudent,
          answers: const {},
        ),
        throwsA(isA<RegistrationException>()),
      );
    });

    test('validates required questions on Mode B events and generates unique ticket', () async {
      final repo = MockRegistrationRepository();
      final founders = MockCampusData.events.firstWhere(
        (e) => e.id == 'evt-founders-table',
      );

      expect(
        () => repo.submitRegistration(
          event: founders,
          student: MockCampusData.currentStudent,
          answers: const {'q-startup': 'TestVenture'},
        ),
        throwsA(isA<RegistrationException>()),
      );

      final created = await repo.submitRegistration(
        event: founders,
        student: MockCampusData.currentStudent,
        answers: const {
          'q-startup': 'TestVenture',
          'q-stage': 'Idea Stage',
        },
      );

      expect(created.ticketCode, startsWith('BU-'));
      expect(created.status, RegistrationStatus.confirmed);
    });
  });
}
