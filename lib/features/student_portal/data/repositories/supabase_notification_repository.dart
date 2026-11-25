import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bennett_campus/core/utils/enum_parsers.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/repositories/notification_repository.dart';

/// Supabase-backed implementation of [NotificationRepository].
class SupabaseNotificationRepository implements NotificationRepository {
  const SupabaseNotificationRepository(this._client);

  final SupabaseClient _client;

  static const String _columns =
      'id, user_id, event_id, title, message, type, is_read, created_at';

  @override
  Future<List<CampusNotification>> fetchNotifications({String? userId}) async {
    if (userId == null || userId.isEmpty) return const [];

    final rows = await _client
        .from('notifications')
        .select(_columns)
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return rows.map(_mapNotification).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  @override
  Future<void> markAsUnread(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': false})
        .eq('id', notificationId);
  }

  @override
  Future<void> markAllAsRead({String? userId}) async {
    if (userId == null || userId.isEmpty) return;
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId);
  }

  @override
  Future<void> addNotification(CampusNotification notification) async {
    // Stage 6 reads server-generated notifications without client inserts.
  }

  static CampusNotification _mapNotification(Map<String, dynamic> row) {
    final createdAt = DateTime.tryParse((row['created_at'] ?? '').toString());
    return CampusNotification(
      id: row['id'].toString(),
      title: (row['title'] as String?)?.trim() ?? 'Campus Update',
      body: (row['message'] as String?)?.trim() ?? '',
      timeAgo: createdAt != null ? _formatRelative(createdAt) : 'Recent',
      type: EnumParsers.parseNotificationType(row['type']),
      isUnread: row['is_read'] != true,
      eventId: row['event_id']?.toString(),
    );
  }

  static String _formatRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
