import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bennett_campus/core/utils/enum_parsers.dart';
import 'package:bennett_campus/features/auth/domain/models/student_user.dart';
import 'package:bennett_campus/features/student_portal/data/repositories/supabase_event_repository.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';
import 'package:bennett_campus/features/student_portal/domain/repositories/registration_repository.dart';

/// Supabase-backed implementation of [RegistrationRepository] using `register_for_event` RPC.
class SupabaseRegistrationRepository implements RegistrationRepository {
  const SupabaseRegistrationRepository(this._client);

  final SupabaseClient _client;

  static const String _selectColumns =
      'id, event_id, student_id, status, qr_token, created_at, updated_at, '
      'events(id, club_id, created_by, title, slug, short_description, description, '
      'category, cover_image_url, start_at, end_at, venue, registration_mode, '
      'capacity, registration_deadline, eligibility, is_team_event, '
      'min_team_size, max_team_size, status, published_at, created_at, updated_at, '
      'clubs(id, name, slug, description, category, logo_url, cover_image_url)), '
      'profiles(full_name, email, department, year_of_study)';

  @override
  Future<List<EventRegistration>> fetchStudentRegistrations(
    String studentId,
  ) async {
    final rows = await _client
        .from('registrations')
        .select(_selectColumns)
        .eq('student_id', studentId)
        .order('created_at', ascending: false);

    return rows.map(_mapRegistrationRow).toList();
  }

  @override
  Future<EventRegistration?> getActiveRegistration({
    required String eventId,
    required String studentId,
  }) async {
    final rows = await _client
        .from('registrations')
        .select(_selectColumns)
        .eq('event_id', eventId)
        .eq('student_id', studentId)
        .eq('status', 'confirmed')
        .limit(1);

    if (rows.isEmpty) return null;
    return _mapRegistrationRow(rows.first);
  }

  @override
  Future<EventRegistration> submitRegistration({
    required CampusEvent event,
    required StudentUser student,
    required Map<String, dynamic> answers,
  }) async {
    if (event.registrationMode == RegistrationMode.advanced) {
      throw const RegistrationException(
        'Advanced custom form submission is not enabled in Stage 6 yet.',
      );
    }

    try {
      final result = await _client.rpc(
        'register_for_event',
        params: {'target_event': event.id},
      );

      final registrationId = result?.toString();
      if (registrationId == null || registrationId.isEmpty) {
        throw const RegistrationException(
          'Registration succeeded, but no registration ID was returned.',
        );
      }

      final createdRow = await _client
          .from('registrations')
          .select(_selectColumns)
          .eq('id', registrationId)
          .maybeSingle();

      if (createdRow != null) {
        return _mapRegistrationRow(createdRow);
      }

      return EventRegistration(
        id: registrationId,
        eventId: event.id,
        studentId: student.id,
        studentName: student.fullName,
        studentEmail: student.email,
        studentProgram: '${student.program} · ${student.batchYear}',
        ticketCode: registrationId.substring(0, 8).toUpperCase(),
        status: RegistrationStatus.confirmed,
        registeredAt: DateTime.now(),
        event: event,
      );
    } on PostgrestException catch (e) {
      throw RegistrationException(_friendlyRpcError(e.message));
    }
  }

  @override
  Future<EventRegistration> cancelRegistration({
    required String registrationId,
  }) async {
    try {
      final updated = await _client
          .from('registrations')
          .update({'status': 'cancelled'})
          .eq('id', registrationId)
          .select(_selectColumns)
          .single();

      return _mapRegistrationRow(updated);
    } on PostgrestException catch (e) {
      throw RegistrationException(_friendlyRpcError(e.message));
    }
  }

  static EventRegistration _mapRegistrationRow(Map<String, dynamic> row) {
    final eventJson = row['events'];
    final mappedEvent = eventJson is Map<String, dynamic>
        ? SupabaseEventRepository.mapEventRow(eventJson)
        : null;

    final profileJson = row['profiles'] is Map<String, dynamic>
        ? row['profiles'] as Map<String, dynamic>
        : null;

    final studentName =
        (profileJson?['full_name'] as String?)?.trim() ?? 'Bennett Student';
    final studentEmail = (profileJson?['email'] as String?)?.trim() ?? '';
    final department =
        (profileJson?['department'] as String?)?.trim() ?? 'Bennett University';
    final year = (profileJson?['year_of_study'] as num?)?.toInt();

    final status = EnumParsers.parseRegistrationStatus(row['status']);
    final createdAt =
        DateTime.tryParse((row['created_at'] ?? '').toString()) ??
        DateTime.now();
    final updatedAt = DateTime.tryParse((row['updated_at'] ?? '').toString());
    final qrToken = (row['qr_token'] as String?)?.trim();
    final idStr = row['id'].toString();

    return EventRegistration(
      id: idStr,
      eventId: row['event_id'].toString(),
      studentId: row['student_id'].toString(),
      studentName: studentName,
      studentEmail: studentEmail,
      studentProgram: year != null ? '$department · Year $year' : department,
      ticketCode: (qrToken != null && qrToken.isNotEmpty)
          ? qrToken
          : idStr.substring(0, idStr.length >= 8 ? 8 : idStr.length).toUpperCase(),
      status: status,
      registeredAt: createdAt,
      cancelledAt: status == RegistrationStatus.cancelled ? updatedAt : null,
      event: mappedEvent,
    );
  }

  static String _friendlyRpcError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('already registered') || lower.contains('duplicate')) {
      return 'You are already registered for this event.';
    }
    if (lower.contains('capacity') || lower.contains('full')) {
      return 'This event has reached full capacity.';
    }
    if (lower.contains('deadline') || lower.contains('closed')) {
      return 'The registration deadline for this event has passed.';
    }
    if (lower.contains('published')) {
      return 'This event is not currently open for registration.';
    }
    if (lower.contains('basic')) {
      return 'This event requires advanced registration, which is not enabled yet.';
    }
    if (lower.contains('authenticated')) {
      return 'Please sign in before registering for an event.';
    }
    return message;
  }
}
