import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';

/// Check-in states for event attendance tracking.
enum AttendanceStatus {
  pending('Not Checked In'),
  checkedIn('Checked In'),
  cancelled('Cancelled Pass');

  const AttendanceStatus(this.label);
  final String label;
}

/// Attendance record tied to a student's registration pass.
class AttendanceCheckInRecord {
  const AttendanceCheckInRecord({
    required this.registrationId,
    required this.eventId,
    required this.ticketCode,
    required this.studentName,
    required this.studentEmail,
    required this.studentProgram,
    required this.status,
    this.checkedInAt,
    this.checkedInBy,
  });

  final String registrationId;
  final String eventId;
  final String ticketCode;
  final String studentName;
  final String studentEmail;
  final String studentProgram;
  final AttendanceStatus status;
  final DateTime? checkedInAt;
  final String? checkedInBy;

  AttendanceCheckInRecord copyWith({
    AttendanceStatus? status,
    DateTime? checkedInAt,
    String? checkedInBy,
  }) {
    return AttendanceCheckInRecord(
      registrationId: registrationId,
      eventId: eventId,
      ticketCode: ticketCode,
      studentName: studentName,
      studentEmail: studentEmail,
      studentProgram: studentProgram,
      status: status ?? this.status,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      checkedInBy: checkedInBy ?? this.checkedInBy,
    );
  }
}

/// Daily registration trend point for analytics charts.
class RegistrationTrendPoint {
  const RegistrationTrendPoint({
    required this.dayLabel,
    required this.count,
  });

  final String dayLabel;
  final int count;
}

/// Event-level registration and attendance summary for analytics.
class EventParticipationSummary {
  const EventParticipationSummary({
    required this.eventId,
    required this.eventTitle,
    required this.registeredCount,
    required this.capacity,
    required this.checkedInCount,
    required this.registrationMode,
  });

  final String eventId;
  final String eventTitle;
  final int registeredCount;
  final int capacity;
  final int checkedInCount;
  final RegistrationMode registrationMode;

  double get attendanceRate =>
      registeredCount == 0 ? 0 : (checkedInCount / registeredCount).clamp(0, 1);
}

/// Raised when QR/manual check-in fails (invalid ticket, cancelled pass, or duplicate).
class CheckInException implements Exception {
  const CheckInException(this.message, {this.isDuplicate = false});

  final String message;
  final bool isDuplicate;

  @override
  String toString() => message;
}
