import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';

/// Repository contract for student notifications.
abstract interface class NotificationRepository {
  Future<List<CampusNotification>> fetchNotifications({String? userId});

  Future<void> markAsRead(String notificationId);

  Future<void> markAsUnread(String notificationId);

  Future<void> markAllAsRead({String? userId});

  Future<void> addNotification(CampusNotification notification);
}
