import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';

/// Registration workflow modes supported by campus events.
enum RegistrationMode {
  basic('One-Click Basic'),
  advanced('Custom Form');

  const RegistrationMode(this.label);
  final String label;
}

/// Supported question field types for organizer-configured registration forms.
enum QuestionFieldType {
  shortText,
  longText,
  singleChoice,
  multipleChoice,
  dropdown,
  checkbox,
  number,
  fileUpload,
}

/// Lifecycle states for a student's event registration.
enum RegistrationStatus {
  confirmed('Confirmed'),
  completed('Completed'),
  cancelled('Cancelled');

  const RegistrationStatus(this.label);
  final String label;
}

/// Single dynamic question configured on an advanced-registration event.
class RegistrationQuestion {
  const RegistrationQuestion({
    required this.id,
    required this.label,
    required this.type,
    this.isRequired = false,
    this.hintText,
    this.helperText,
    this.options = const [],
  });

  final String id;
  final String label;
  final QuestionFieldType type;
  final bool isRequired;
  final String? hintText;
  final String? helperText;
  final List<String> options;
}

/// Lightweight attachment summary for file-upload registration questions.
class UploadedFileMetadata {
  const UploadedFileMetadata({
    required this.fileName,
    required this.sizeBytes,
  });

  final String fileName;
  final int sizeBytes;

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    final kb = sizeBytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
}

/// Persisted-shape UI model for an event registration and ticket.
class EventRegistration {
  const EventRegistration({
    required this.id,
    required this.eventId,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.studentProgram,
    required this.ticketCode,
    required this.status,
    required this.registeredAt,
    this.cancelledAt,
    this.answers = const {},
    this.event,
  });

  final String id;
  final String eventId;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String studentProgram;
  final String ticketCode;
  final RegistrationStatus status;
  final DateTime registeredAt;
  final DateTime? cancelledAt;
  final Map<String, dynamic> answers;
  final CampusEvent? event;

  EventRegistration copyWith({
    RegistrationStatus? status,
    DateTime? cancelledAt,
    CampusEvent? event,
  }) {
    return EventRegistration(
      id: id,
      eventId: eventId,
      studentId: studentId,
      studentName: studentName,
      studentEmail: studentEmail,
      studentProgram: studentProgram,
      ticketCode: ticketCode,
      status: status ?? this.status,
      registeredAt: registeredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      answers: answers,
      event: event ?? this.event,
    );
  }
}

/// Domain exception raised by registration validation or capacity checks.
class RegistrationException implements Exception {
  const RegistrationException(this.message);

  final String message;

  @override
  String toString() => message;
}
