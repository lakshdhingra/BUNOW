import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bennett_campus/app.dart';

void main() {
  testWidgets(
    'Stage 3 Mode A & B registration, ticket confirmation, edge cases, and My Events tabs work',
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

      // Mode A: One-click basic registration flow.
      await tester.tap(find.text('Explore').first);
      await tester.pumpAndSettle();

      final uphaarCard = find.text('Uphaar Acoustic & Indie Live Night').first;
      await tester.ensureVisible(uphaarCard);
      await tester.pumpAndSettle();
      await tester.tap(uphaarCard);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Register Now'));
      await tester.tap(find.text('Register Now'));
      await tester.pumpAndSettle();

      expect(find.text('Quick Event Registration'), findsOneWidget);
      expect(find.text('Auto-filled'), findsOneWidget);
      expect(find.text('Aarav Sharma'), findsWidgets);
      await tester.ensureVisible(find.text('Confirm Registration'));
      await tester.tap(find.text('Confirm Registration'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();

      expect(find.text('Registration Confirmed!'), findsOneWidget);
      expect(find.textContaining('BU-ADV-'), findsOneWidget);

      // Mode B: Custom form validation + submission.
      await tester.tap(find.text('Explore').first);
      await tester.pumpAndSettle();
      final foundersCard = find.text('Bennett Hatchery Founders Roundtable').first;
      await tester.ensureVisible(foundersCard);
      await tester.pumpAndSettle();
      await tester.tap(foundersCard);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Register Now'));
      await tester.tap(find.text('Register Now'));
      await tester.pumpAndSettle();

      expect(find.text('Event Registration Form'), findsOneWidget);
      await tester.ensureVisible(find.text('Complete Registration'));
      await tester.tap(find.text('Complete Registration'));
      await tester.pumpAndSettle();
      expect(find.text('This field is required.'), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField).first,
        'CampusFlow AI',
      );
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('MVP Built').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Complete Registration'));
      await tester.tap(find.text('Complete Registration'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();
      expect(find.text('Registration Confirmed!'), findsOneWidget);

      // My Events: Upcoming, Completed, Cancelled, and Registration History tabs.
      await tester.tap(find.text('My Events').first);
      await tester.pumpAndSettle();
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text('Registration History'), findsOneWidget);

      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();
      expect(find.text('Bennovate Startup Expo 2026'), findsOneWidget);

      await tester.tap(find.text('Cancelled'));
      await tester.pumpAndSettle();
      expect(find.text('Ticket BU-BEN-2740'), findsOneWidget);

      // Verify mobile viewport renders My Events without overflow.
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(find.text('My Events'), findsWidgets);
    },
  );
}
