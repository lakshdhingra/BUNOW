import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';

/// Repository contract for student notifications (mocked in Stage 5).
abstract interface class NotificationRepository {
  Future<List<CampusNotification>> fetchNotifications();

  Future<void> markAsRead(String notificationId);

  Future<void> markAsUnread(String notificationId);

  Future<void> markAllAsRead();

  Future<void> addNotification(CampusNotification notification);
}
