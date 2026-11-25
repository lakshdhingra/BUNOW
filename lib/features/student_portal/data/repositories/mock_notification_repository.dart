import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/repositories/notification_repository.dart';

/// Stateful in-memory mock implementation of [NotificationRepository].
class MockNotificationRepository implements NotificationRepository {
  MockNotificationRepository()
    : _items = List<CampusNotification>.from(MockCampusData.notifications);

  final List<CampusNotification> _items;

  @override
  Future<List<CampusNotification>> fetchNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return List<CampusNotification>.unmodifiable(_items);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final index = _items.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(isUnread: false);
    }
  }

  @override
  Future<void> markAsUnread(String notificationId) async {
    final index = _items.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(isUnread: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isUnread: false);
    }
  }

  @override
  Future<void> addNotification(CampusNotification notification) async {
    _items.insert(0, notification);
  }
}
