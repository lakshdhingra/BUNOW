import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bennett_campus/core/utils/enum_parsers.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';
import 'package:bennett_campus/features/student_portal/domain/repositories/event_repository.dart';

/// Supabase-backed implementation of [EventRepository].
class SupabaseEventRepository implements EventRepository {
  const SupabaseEventRepository(this._client);

  final SupabaseClient _client;

  static const String _eventColumns =
      'id, club_id, created_by, title, slug, short_description, description, '
      'category, cover_image_url, start_at, end_at, venue, registration_mode, '
      'capacity, registration_deadline, eligibility, is_team_event, '
      'min_team_size, max_team_size, status, published_at, created_at, updated_at, '
      'clubs(id, name, slug, description, category, logo_url, cover_image_url), '
      'registrations(status)';

  @override
  Future<List<CampusEvent>> fetchPublishedEvents() async {
    final rows = await _client
        .from('events')
        .select(_eventColumns)
        .eq('status', 'published')
        .order('start_at', ascending: true);

    return rows.map((row) => mapEventRow(row)).toList();
  }

  @override
  Future<CampusEvent?> fetchEventById(String eventId) async {
    final row = await _client
        .from('events')
        .select(_eventColumns)
        .eq('id', eventId)
        .maybeSingle();

    if (row == null) return null;

    final mediaRows = await _client
        .from('event_media')
        .select(
          'id, event_id, media_type, storage_path, external_url, caption, sort_order, created_at',
        )
        .eq('event_id', eventId)
        .order('sort_order', ascending: true);

    final questionRows = await _client
        .from('form_questions')
        .select(
          'id, event_id, question, question_type, options, is_required, sort_order, created_at',
        )
        .eq('event_id', eventId)
        .order('sort_order', ascending: true);

    final mediaItems = mediaRows.map(_mapMediaRow).toList();
    final photos = mediaItems
        .where((m) => m.kind == MediaKind.photo)
        .toList();
    final videos = mediaItems
        .where((m) => m.kind == MediaKind.video)
        .toList();
    final questions = questionRows.map(_mapQuestionRow).toList();

    return mapEventRow(
      row,
      mediaGallery: photos,
      promoVideos: videos,
      questions: questions,
    );
  }

  static CampusEvent mapEventRow(
    Map<String, dynamic> row, {
    List<MediaItem> mediaGallery = const [],
    List<MediaItem> promoVideos = const [],
    List<RegistrationQuestion> questions = const [],
  }) {
    final clubMap = row['clubs'] is Map<String, dynamic>
        ? row['clubs'] as Map<String, dynamic>
        : null;

    final regList = row['registrations'] is List
        ? row['registrations'] as List
        : const [];
    final activeRegCount = regList.where((r) {
      if (r is! Map) return false;
      final status = (r['status'] ?? '').toString().toLowerCase();
      return status != 'cancelled' && status != 'canceled';
    }).length;

    final startAt =
        DateTime.tryParse((row['start_at'] ?? '').toString()) ?? DateTime.now();
    final endAt =
        DateTime.tryParse((row['end_at'] ?? '').toString()) ?? startAt;
    final publishedAt =
        DateTime.tryParse((row['published_at'] ?? '').toString()) ??
        DateTime.tryParse((row['created_at'] ?? '').toString()) ??
        startAt;
    final deadline =
        DateTime.tryParse((row['registration_deadline'] ?? '').toString()) ??
        startAt;

    final isTeam = row['is_team_event'] == true;
    final minTeam = (row['min_team_size'] as num?)?.toInt();
    final maxTeam = (row['max_team_size'] as num?)?.toInt();
    final teamSizeLabel = isTeam
        ? (minTeam != null && maxTeam != null
              ? 'Teams of $minTeam–$maxTeam'
              : 'Team Event')
        : 'Individual';

    final statusStr = (row['status'] ?? '').toString().toLowerCase();
    final isCompleted = statusStr == 'completed';
    final isClosed =
        isCompleted ||
        statusStr == 'cancelled' ||
        deadline.isBefore(DateTime.now());

    return CampusEvent(
      id: row['id'].toString(),
      title: (row['title'] as String?)?.trim() ?? 'Campus Event',
      subtitle: (row['short_description'] as String?)?.trim() ?? '',
      description: (row['description'] as String?)?.trim() ?? '',
      clubId: (row['club_id'] ?? clubMap?['id'] ?? '').toString(),
      clubName: (clubMap?['name'] as String?)?.trim() ?? 'Bennett Club',
      category: EnumParsers.parseEventCategory(row['category']),
      startTime: startAt,
      endTime: endAt,
      publishedAt: publishedAt,
      registrationDeadline: deadline,
      venue: (row['venue'] as String?)?.trim() ?? 'Bennett Campus',
      bannerUrl: (row['cover_image_url'] as String?)?.trim() ?? '',
      registeredCount: activeRegCount,
      capacity: (row['capacity'] as num?)?.toInt() ?? 100,
      teamSizeLabel: teamSizeLabel,
      feeLabel: (row['eligibility'] as String?)?.trim().isNotEmpty == true
          ? (row['eligibility'] as String).trim()
          : 'Bennett Students',
      registrationMode: EnumParsers.parseRegistrationMode(
        row['registration_mode'],
      ),
      registrationQuestions: questions,
      isRegistrationClosed: isClosed,
      isCompleted: isCompleted,
      mediaGallery: mediaGallery,
      promoVideos: promoVideos,
    );
  }

  static MediaItem _mapMediaRow(Map<String, dynamic> row) {
    final externalUrl = (row['external_url'] as String?)?.trim() ?? '';
    final storagePath = (row['storage_path'] as String?)?.trim() ?? '';
    final resolvedUrl = externalUrl.isNotEmpty
        ? externalUrl
        : (storagePath.startsWith('http') ? storagePath : '');
    final kind = EnumParsers.parseMediaKind(row['media_type']);

    return MediaItem(
      id: row['id'].toString(),
      url: resolvedUrl,
      caption: (row['caption'] as String?)?.trim() ?? '',
      kind: kind,
      section: kind == MediaKind.video
          ? MediaSection.promo
          : MediaSection.gallery,
      orderIndex: (row['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  static RegistrationQuestion _mapQuestionRow(Map<String, dynamic> row) {
    final rawOptions = row['options'];
    final options = rawOptions is List
        ? rawOptions.map((e) => e.toString()).toList()
        : const <String>[];

    return RegistrationQuestion(
      id: row['id'].toString(),
      label: (row['question'] as String?)?.trim() ?? 'Question',
      type: EnumParsers.parseQuestionFieldType(row['question_type']),
      isRequired: row['is_required'] == true,
      options: options,
    );
  }
}
