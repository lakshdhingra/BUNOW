import 'package:bennett_campus/features/organizer_studio/domain/models/attendance_models.dart';
import 'package:bennett_campus/features/organizer_studio/domain/models/organizer_models.dart';
import 'package:bennett_campus/features/organizer_studio/domain/repositories/attendance_repository.dart';
import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';

/// In-memory mock implementation of [AttendanceRepository] for Stage 5.
class MockAttendanceRepository implements AttendanceRepository {
  MockAttendanceRepository() : _records = _seedRecords();

  final List<AttendanceCheckInRecord> _records;

  static List<AttendanceCheckInRecord> _seedRecords() {
    final seed = <AttendanceCheckInRecord>[
      AttendanceCheckInRecord(
        registrationId: 'reg-hackaccino-01',
        eventId: 'evt-hackaccino',
        ticketCode: 'BU-CSI-4821',
        studentName: MockCampusData.currentStudent.fullName,
        studentEmail: MockCampusData.currentStudent.email,
        studentProgram:
            '${MockCampusData.currentStudent.program} · ${MockCampusData.currentStudent.batchYear}',
        status: AttendanceStatus.pending,
      ),
      AttendanceCheckInRecord(
        registrationId: 'reg-org-101',
        eventId: 'evt-hackaccino',
        ticketCode: 'BU-CSI-4822',
        studentName: 'Diya Mehta',
        studentEmail: 'e23cseu0281@bennett.edu.in',
        studentProgram: 'B.Tech AI · Batch of 2027',
        status: AttendanceStatus.checkedIn,
        checkedInAt: DateTime(2026, 11, 26, 9, 14),
        checkedInBy: 'Pranav Joshi',
      ),
      const AttendanceCheckInRecord(
        registrationId: 'reg-org-102',
        eventId: 'evt-hackaccino',
        ticketCode: 'BU-CSI-4829',
        studentName: 'Kabir Malhotra',
        studentEmail: 'e24cseu0094@bennett.edu.in',
        studentProgram: 'B.Tech CSE · Batch of 2028',
        status: AttendanceStatus.pending,
      ),
      const AttendanceCheckInRecord(
        registrationId: 'reg-org-103',
        eventId: 'evt-floodlight-cup',
        ticketCode: 'BU-CSI-4901',
        studentName: 'Rohan Nair',
        studentEmail: 'e22bba0048@bennett.edu.in',
        studentProgram: 'BBA · Batch of 2026',
        status: AttendanceStatus.cancelled,
      ),
      AttendanceCheckInRecord(
        registrationId: 'reg-org-104',
        eventId: 'evt-flutter-web',
        ticketCode: 'BU-GDG-5012',
        studentName: 'Niharika Singh',
        studentEmail: 'e23cseu0315@bennett.edu.in',
        studentProgram: 'B.Tech CSE · Batch of 2027',
        status: AttendanceStatus.checkedIn,
        checkedInAt: DateTime(2026, 11, 26, 16, 48),
        checkedInBy: 'Devansh Kulkarni',
      ),
      const AttendanceCheckInRecord(
        registrationId: 'reg-org-105',
        eventId: 'evt-cloud-bootcamp',
        ticketCode: 'BU-GDG-5028',
        studentName: 'Aditya Verma',
        studentEmail: 'e22cseu0198@bennett.edu.in',
        studentProgram: 'B.Tech CSE · Batch of 2026',
        status: AttendanceStatus.pending,
      ),
      AttendanceCheckInRecord(
        registrationId: 'reg-bennovate-03',
        eventId: 'evt-bennovate-past',
        ticketCode: 'BU-BEN-1094',
        studentName: MockCampusData.currentStudent.fullName,
        studentEmail: MockCampusData.currentStudent.email,
        studentProgram:
            '${MockCampusData.currentStudent.program} · ${MockCampusData.currentStudent.batchYear}',
        status: AttendanceStatus.checkedIn,
        checkedInAt: DateTime(2026, 10, 18, 10, 5),
        checkedInBy: 'Vivaan Kapoor',
      ),
    ];
    return seed;
  }

  @override
  Future<List<AttendanceCheckInRecord>> fetchEventAttendance(
    String eventId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _records.where((r) => r.eventId == eventId).toList();
  }

  @override
  Future<AttendanceCheckInRecord?> fetchStudentAttendanceForEvent({
    required String eventId,
    required String studentEmail,
  }) async {
    for (final r in _records) {
      if (r.eventId == eventId && r.studentEmail == studentEmail) {
        return r;
      }
    }
    return null;
  }

  @override
  Future<AttendanceCheckInRecord> checkInByTicketCode({
    required String eventId,
    required String ticketCode,
    required String checkedInBy,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final normalized = ticketCode.trim().toUpperCase();
    final index = _records.indexWhere(
      (r) => r.eventId == eventId && r.ticketCode.toUpperCase() == normalized,
    );
    if (index < 0) {
      throw CheckInException(
        'No valid pass found for ticket "$normalized" in this event.',
      );
    }
    return _performCheckIn(index, checkedInBy);
  }

  @override
  Future<AttendanceCheckInRecord> checkInManually({
    required String eventId,
    required String registrationId,
    required String checkedInBy,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final index = _records.indexWhere(
      (r) => r.eventId == eventId && r.registrationId == registrationId,
    );
    if (index < 0) {
      throw const CheckInException('Participant registration not found.');
    }
    return _performCheckIn(index, checkedInBy);
  }

  AttendanceCheckInRecord _performCheckIn(int index, String checkedInBy) {
    final current = _records[index];
    if (current.status == AttendanceStatus.cancelled) {
      throw CheckInException(
        'Pass ${current.ticketCode} was cancelled and cannot be checked in.',
      );
    }
    if (current.status == AttendanceStatus.checkedIn) {
      throw CheckInException(
        'Duplicate check-in prevented: ${current.studentName} (${current.ticketCode}) is already checked in.',
        isDuplicate: true,
      );
    }
    final updated = current.copyWith(
      status: AttendanceStatus.checkedIn,
      checkedInAt: DateTime.now(),
      checkedInBy: checkedInBy,
    );
    _records[index] = updated;
    return updated;
  }

  @override
  Future<List<RegistrationTrendPoint>> fetchRegistrationTrends(
    String clubId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (clubId == 'club-gdg') {
      return const [
        RegistrationTrendPoint(dayLabel: 'Thu', count: 14),
        RegistrationTrendPoint(dayLabel: 'Fri', count: 22),
        RegistrationTrendPoint(dayLabel: 'Sat', count: 31),
        RegistrationTrendPoint(dayLabel: 'Sun', count: 28),
        RegistrationTrendPoint(dayLabel: 'Mon', count: 42),
        RegistrationTrendPoint(dayLabel: 'Tue', count: 39),
        RegistrationTrendPoint(dayLabel: 'Wed', count: 54),
      ];
    }
    return const [
      RegistrationTrendPoint(dayLabel: 'Thu', count: 24),
      RegistrationTrendPoint(dayLabel: 'Fri', count: 38),
      RegistrationTrendPoint(dayLabel: 'Sat', count: 52),
      RegistrationTrendPoint(dayLabel: 'Sun', count: 47),
      RegistrationTrendPoint(dayLabel: 'Mon', count: 69),
      RegistrationTrendPoint(dayLabel: 'Tue', count: 84),
      RegistrationTrendPoint(dayLabel: 'Wed', count: 96),
    ];
  }

  @override
  Future<List<EventParticipationSummary>> fetchParticipationSummaries({
    required String clubId,
    required List<OrganizerEventRecord> events,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    return events
        .where((e) => e.clubId == clubId)
        .map((event) {
          final checkedInBase = _records
              .where(
                (r) =>
                    r.eventId == event.id &&
                    r.status == AttendanceStatus.checkedIn,
              )
              .length;
          final mockAttendance = event.status == OrganizerEventStatus.completed
              ? (event.registeredCount * 0.88).round()
              : (event.registeredCount > 20
                    ? (event.registeredCount * 0.42).round() + checkedInBase
                    : checkedInBase);
          return EventParticipationSummary(
            eventId: event.id,
            eventTitle: event.title,
            registeredCount: event.registeredCount,
            capacity: event.capacity,
            checkedInCount: mockAttendance.clamp(0, event.registeredCount),
            registrationMode: event.registrationMode,
          );
        })
        .toList();
  }
}
