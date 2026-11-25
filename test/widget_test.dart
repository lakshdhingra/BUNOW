import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bennett_campus/app.dart';

void main() {
  testWidgets('Login flow and Student Portal navigation work across desktop and mobile', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: BennettApp()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to BENNETT'), findsOneWidget);
    expect(find.text('Continue with Microsoft'), findsOneWidget);

    await tester.tap(find.text('Continue with Microsoft'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back, Aarav'), findsOneWidget);
    expect(find.text('FEATURED EVENT'), findsOneWidget);

    await tester.tap(find.text('Explore').first);
    await tester.pumpAndSettle();
    expect(find.text('Explore Events'), findsOneWidget);

    await tester.tap(find.text('Calendar').first);
    await tester.pumpAndSettle();
    expect(find.text('Campus Calendar'), findsOneWidget);

    await tester.tap(find.text('My Events').first);
    await tester.pumpAndSettle();
    expect(find.text('My Events'), findsWidgets);

    await tester.tap(find.text('Clubs').first);
    await tester.pumpAndSettle();
    expect(find.text('Clubs & Chapters'), findsOneWidget);

    await tester.tap(find.text('Highlights').first);
    await tester.pumpAndSettle();
    expect(find.text('Campus Highlights'), findsOneWidget);

    await tester.tap(find.text('Profile').first);
    await tester.pumpAndSettle();
    expect(find.text('Student Profile'), findsOneWidget);

    // Verify mobile viewport renders without overflow errors.
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home').first);
    await tester.pumpAndSettle();
    expect(find.text('Welcome back, Aarav'), findsOneWidget);
  });
}
