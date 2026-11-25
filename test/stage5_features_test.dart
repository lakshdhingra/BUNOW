import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bennett_campus/app.dart';
import 'package:bennett_campus/features/auth/presentation/providers/auth_provider.dart';
import 'package:bennett_campus/features/organizer_studio/data/repositories/mock_attendance_repository.dart';
import 'package:bennett_campus/features/organizer_studio/domain/models/attendance_models.dart';
import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';
import 'package:bennett_campus/features/student_portal/data/repositories/mock_notification_repository.dart';

class _TestAuthController extends AuthController {
  @override
  AuthState build() => const AuthState(user: MockCampusData.currentStudent);
}

void main() {
  group('Stage 5 repositories', () {
    test('MockNotificationRepository tracks read and unread state', () async {
      final repo = MockNotificationRepository();
      final initial = await repo.fetchNotifications();
      expect(initial.where((n) => n.isUnread).length, 3);

      await repo.markAsRead(initial.first.id);
      final afterOne = await repo.fetchNotifications();
      expect(afterOne.where((n) => n.isUnread).length, 2);

      await repo.markAllAsRead();
      final afterAll = await repo.fetchNotifications();
      expect(afterAll.where((n) => n.isUnread), isEmpty);
    });

    test('MockAttendanceRepository checks in tickets and prevents duplicates', () async {
      final repo = MockAttendanceRepository();

      final checkedIn = await repo.checkInByTicketCode(
        eventId: 'evt-hackaccino',
        ticketCode: 'BU-CSI-4821',
        checkedInBy: 'Pranav Joshi',
      );
      expect(checkedIn.status, AttendanceStatus.checkedIn);

      expect(
        () => repo.checkInByTicketCode(
          eventId: 'evt-hackaccino',
          ticketCode: 'BU-CSI-4821',
          checkedInBy: 'Pranav Joshi',
        ),
        throwsA(
          predicate<CheckInException>((e) => e.isDuplicate),
        ),
      );
    });
  });

  testWidgets(
    'Stage 5 media embeds, notification center, attendance check-in, and analytics work',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(_TestAuthController.new),
          ],
          child: const BennettApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Media: Verify Event Detail promotional video, photo gallery, and recap media.
      await tester.tap(find.text('Event Details'));
      await tester.pumpAndSettle();
      expect(find.text('Promotional Video'), findsOneWidget);
      expect(find.text('Event Photo Gallery'), findsOneWidget);
      expect(find.text('Event Recap Media'), findsOneWidget);

      final promoFinder = find.textContaining(
        'Hackaccino 4.0 Official Teaser & Track Reveal',
      );
      await tester.ensureVisible(promoFinder);
      await tester.tap(promoFinder);
      await tester.pumpAndSettle();
      expect(find.text('Open Source'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Notifications: Open Notification Center, filter, and navigate to event.
      await tester.tap(find.byTooltip('Notifications'));
      await tester.pumpAndSettle();
      expect(find.text('Notification Center'), findsOneWidget);
      expect(find.text('Unread'), findsOneWidget);

      await tester.tap(find.text('View Event').first);
      await tester.pumpAndSettle();
      expect(find.text('About this Event'), findsOneWidget);

      // Organizer Studio: Verify Analytics & Attendance check-in with duplicate guard.
      await tester.tap(find.text('Organizer Studio'));
      await tester.pumpAndSettle();
      expect(find.text('Registration Trends'), findsOneWidget);
      expect(find.text('Event Participation Summaries'), findsOneWidget);

      await tester.tap(find.text('Attendance').first);
      await tester.pumpAndSettle();
      expect(find.text('Attendance & Check-In'), findsOneWidget);
      expect(find.text('QR Ticket Scanner'), findsOneWidget);
      expect(find.text('Manual Student Lookup'), findsOneWidget);

      await tester.tap(find.widgetWithText(ActionChip, 'BU-CSI-4821'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Checked in Aarav Sharma'), findsOneWidget);

      await tester.tap(find.widgetWithText(ActionChip, 'BU-CSI-4821'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Duplicate check-in prevented'), findsOneWidget);

      // Verify mobile viewport layout renders cleanly without overflow.
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(find.text('Attendance & Check-In'), findsOneWidget);
    },
  );
}
