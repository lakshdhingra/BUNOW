import 'package:flutter_test/flutter_test.dart';
import 'package:bennett_campus/core/utils/csv_exporter.dart';
import 'package:bennett_campus/features/organizer_studio/data/repositories/mock_organizer_repository.dart';
import 'package:bennett_campus/features/organizer_studio/domain/models/organizer_models.dart';

void main() {
  group('MockOrganizerRepository & CsvExporter', () {
    test('duplicates and cancels club events cleanly', () async {
      final repo = MockOrganizerRepository();
      final initial = await repo.fetchClubEvents('club-csi');
      expect(initial, isNotEmpty);

      final first = initial.first;
      final duplicated = await repo.duplicateEvent(first.id);
      expect(duplicated.status, OrganizerEventStatus.draft);
      expect(duplicated.title, contains('(Copy)'));

      final cancelled = await repo.cancelEvent(duplicated.id);
      expect(cancelled.status, OrganizerEventStatus.cancelled);
    });

    test('adds, updates, and removes club representatives', () async {
      final repo = MockOrganizerRepository();
      final rep = await repo.addRepresentative(
        clubId: 'club-csi',
        name: 'Tanya Gupta',
        email: 'e23cseu0555@bennett.edu.in',
        program: 'B.Tech CSE · Year 3',
        role: OrganizerRole.eventManager,
      );

      final updated = await repo.updateRepresentativeRole(
        representativeId: rep.id,
        role: OrganizerRole.admin,
      );
      expect(updated.role, OrganizerRole.admin);

      await repo.removeRepresentative(rep.id);
      final reps = await repo.fetchRepresentatives('club-csi');
      expect(reps.any((r) => r.id == rep.id), isFalse);
    });

    test('exports escaped CSV rows for club participants', () async {
      final repo = MockOrganizerRepository();
      final regs = await repo.fetchClubRegistrations('club-csi');
      final events = await repo.fetchClubEvents('club-csi');
      final titles = {for (final e in events) e.id: e.title};

      final csv = CsvExporter.buildParticipantsCsv(
        registrations: regs,
        eventTitlesById: titles,
      );
      expect(csv, contains('Ticket Code,Student Name,Email'));
      expect(csv, contains('BU-CSI-4821'));
    });
  });
}
