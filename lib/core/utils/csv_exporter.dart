import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';

/// Builds RFC-4180 CSV content for participant exports.
abstract final class CsvExporter {
  static String buildParticipantsCsv({
    required List<EventRegistration> registrations,
    required Map<String, String> eventTitlesById,
  }) {
    final buffer = StringBuffer()
      ..writeln('Ticket Code,Student Name,Email,Program,Event,Status,Registered At,Responses');

    for (final reg in registrations) {
      final eventTitle = eventTitlesById[reg.eventId] ?? reg.eventId;
      final responses = reg.answers.entries
          .map((e) => '${e.key}: ${_stringify(e.value)}')
          .join(' | ');

      buffer.writeln(
        [
          reg.ticketCode,
          reg.studentName,
          reg.studentEmail,
          reg.studentProgram,
          eventTitle,
          reg.status.label,
          reg.registeredAt.toIso8601String(),
          responses,
        ].map(_escape).join(','),
      );
    }
    return buffer.toString();
  }

  static String _stringify(dynamic value) {
    if (value is UploadedFileMetadata) {
      return '${value.fileName} (${value.formattedSize})';
    }
    if (value is List) return value.join('; ');
    return value.toString();
  }

  static String _escape(String raw) {
    final needsQuotes =
        raw.contains(',') || raw.contains('"') || raw.contains('\n');
    if (!needsQuotes) return raw;
    return '"${raw.replaceAll('"', '""')}"';
  }
}
