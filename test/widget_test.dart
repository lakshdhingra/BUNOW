import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bennett_campus/app.dart';

void main() {
  testWidgets(
    'Stage 2 discovery, event detail, and club profile navigation work across desktop and mobile',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const ProviderScope(child: BennettApp()));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to BENNETT'), findsOneWidget);
      await tester.tap(find.text('Continue with Microsoft'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back, Aarav'), findsOneWidget);

      // Navigate to Explore Events and open an Event Detail page.
      await tester.tap(find.text('Explore').first);
      await tester.pumpAndSettle();
      expect(find.text('Explore Events'), findsOneWidget);
      expect(find.text('Sort By'), findsOneWidget);

      await tester.tap(find.text('Hackaccino 4.0 — 36-Hour Campus Hackathon').first);
      await tester.pumpAndSettle();
      expect(find.text('About this Event'), findsOneWidget);
      expect(find.text('Event Agenda'), findsOneWidget);
      expect(find.text('Registration Information'), findsOneWidget);
      expect(find.text('Related Events'), findsOneWidget);

      // Navigate from Event Detail club action to Club Profile page.
      await tester.ensureVisible(find.text('View CSI Club Profile'));
      await tester.tap(find.text('View CSI Club Profile'));
      await tester.pumpAndSettle();
      expect(find.text('About CSI Bennett Chapter'), findsOneWidget);
      expect(find.text('Upcoming Events'), findsOneWidget);
      expect(find.text('Previous Events'), findsOneWidget);
      expect(find.text('Club Leadership'), findsOneWidget);

      // Navigate to Clubs directory and test mobile layout with zero overflow.
      await tester.tap(find.text('Clubs').first);
      await tester.pumpAndSettle();
      expect(find.text('Clubs & Chapters'), findsOneWidget);

      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Explore').first);
      await tester.pumpAndSettle();
      expect(find.text('Explore Events'), findsOneWidget);
    },
  );
}
