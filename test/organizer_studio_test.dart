import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bennett_campus/app.dart';

void main() {
  testWidgets(
    'Stage 4 Organizer Studio dashboard, event wizard, form builder, registrations, and club management work',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const ProviderScope(child: BennettApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Microsoft'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();

      // Open Organizer Studio from Student Portal sidebar.
      await tester.tap(find.text('Organizer Studio'));
      await tester.pumpAndSettle();
      expect(find.text('CSI Bennett Chapter Dashboard'), findsOneWidget);
      expect(find.text('Registration Analytics'), findsOneWidget);
      expect(find.text('Recent Activity'), findsOneWidget);

      // Navigate to Event Management and verify status tabs.
      await tester.tap(find.text('Events').first);
      await tester.pumpAndSettle();
      expect(find.text('Event Management'), findsOneWidget);
      expect(find.text('Drafts'), findsOneWidget);
      expect(find.text('Published'), findsWidgets);

      // Launch 6-step Event Creation Wizard + Dynamic Form Builder.
      await tester.tap(find.text('Create Event').first);
      await tester.pumpAndSettle();
      expect(find.text('1. Basic Information'), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Distributed Systems Lab',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Hands-on Raft consensus workshop',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'Build a fault-tolerant key-value node in 3 hours.',
      );
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('2. Event Media & Poster'), findsOneWidget);

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('3. Date, Time & Venue'), findsOneWidget);

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('4. Registration Mode'), findsOneWidget);

      // Select Mode B Custom Form and add a question in DynamicFormBuilder.
      await tester.tap(find.text('Mode B · Advanced Custom Form'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Custom Form Builder'), findsOneWidget);

      await tester.tap(find.text('Add First Question'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'GitHub Username',
      );
      await tester.tap(find.text('Save Question'));
      await tester.pumpAndSettle();
      expect(find.text('GitHub Username'), findsOneWidget);

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('6. Preview & Publish'), findsWidgets);
      expect(find.text('Publish Event'), findsOneWidget);

      await tester.ensureVisible(find.text('Publish Event'));
      await tester.tap(find.text('Publish Event'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Distributed Systems Lab'), findsOneWidget);

      // Navigate to Registration Management and open CSV export.
      await tester.tap(find.text('Registrations').first);
      await tester.pumpAndSettle();
      expect(find.text('Registration Management'), findsOneWidget);
      await tester.tap(find.text('Export CSV'));
      await tester.pumpAndSettle();
      expect(find.text('Participant CSV Export'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Navigate to Club Settings and verify mobile layout without overflow.
      await tester.tap(find.text('Club Settings').first);
      await tester.pumpAndSettle();
      expect(find.text('Club Management & Access'), findsOneWidget);
      expect(find.text('Authorized Representatives'), findsOneWidget);

      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(find.text('Club Management & Access'), findsOneWidget);
    },
  );
}
