import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bennett_campus/app.dart';
import 'package:bennett_campus/features/auth/presentation/providers/auth_provider.dart';
import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';

class _TestAuthController extends AuthController {
  @override
  AuthState build() => const AuthState();

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthState(user: MockCampusData.currentStudent);
  }
}

void main() {
  testWidgets(
    'Stage 6 login form, discovery, Mode A registration, and My Events work cleanly',
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

      expect(find.text('Welcome to BENNETT'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'e23cseu0142@bennett.edu.in',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back, Aarav'), findsOneWidget);

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
      await tester.ensureVisible(find.text('Confirm Registration'));
      await tester.tap(find.text('Confirm Registration'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();

      expect(find.text('Registration Confirmed!'), findsOneWidget);
      expect(find.textContaining('BU-ADV-'), findsOneWidget);

      // Mode B shows deferred notice in Stage 6.
      await tester.tap(find.text('Explore').first);
      await tester.pumpAndSettle();
      final foundersCard =
          find.text('Bennett Hatchery Founders Roundtable').first;
      await tester.ensureVisible(foundersCard);
      await tester.pumpAndSettle();
      await tester.tap(foundersCard);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Register Now'));
      await tester.tap(find.text('Register Now'));
      await tester.pumpAndSettle();
      expect(find.text('Advanced Registration Pending'), findsOneWidget);

      // My Events tabs.
      await tester.tap(find.text('My Events').first);
      await tester.pumpAndSettle();
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);

      // Verify mobile viewport renders My Events without overflow.
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(find.text('My Events'), findsWidgets);
    },
  );
}
