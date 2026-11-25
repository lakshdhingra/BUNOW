import 'package:flutter_test/flutter_test.dart';
import 'package:bennett_campus/core/utils/enum_parsers.dart';
import 'package:bennett_campus/features/auth/domain/models/student_user.dart';
import 'package:bennett_campus/features/student_portal/data/repositories/supabase_event_repository.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';

void main() {
  group('Stage 6 Supabase mappers & enum parsers', () {
    test('maps profiles row and fallback missing profile cleanly', () {
      final user = StudentUser.fromProfileMap({
        'id': 'user-uuid-1',
        'full_name': 'Aarav Sharma',
        'email': 'aarav@bennett.edu.in',
        'enrollment_number': 'E23CSEU0142',
        'department': 'Computer Science',
        'year_of_study': 3,
        'interests': ['AI', 'Flutter'],
        'onboarding_completed': true,
      }, authorizedClubIds: ['club-1']);

      expect(user.id, 'user-uuid-1');
      expect(user.fullName, 'Aarav Sharma');
      expect(user.enrollmentNumber, 'E23CSEU0142');
      expect(user.program, 'Computer Science');
      expect(user.batchYear, 'Year 3');
      expect(user.interests, ['AI', 'Flutter']);
      expect(user.isProfileMissing, isFalse);
      expect(user.isOrganizer, isTrue);

      final fallback = StudentUser.fallbackFromAuth(
        id: 'user-uuid-2',
        email: 'newstudent@bennett.edu.in',
      );
      expect(fallback.isProfileMissing, isTrue);
      expect(fallback.email, 'newstudent@bennett.edu.in');
    });

    test('parses database enum strings defensively', () {
      expect(
        EnumParsers.parseEventCategory('tech_ai'),
        EventCategory.techAi,
      );
      expect(
        EnumParsers.parseRegistrationMode('basic'),
        RegistrationMode.basic,
      );
      expect(
        EnumParsers.parseRegistrationMode('advanced'),
        RegistrationMode.advanced,
      );
      expect(
        EnumParsers.parseRegistrationStatus('confirmed'),
        RegistrationStatus.confirmed,
      );
      expect(
        EnumParsers.parseNotificationType('registration_confirmed'),
        NotificationType.registrationConfirmation,
      );
    });

    test('maps Supabase events row with embedded clubs and registrations', () {
      final event = SupabaseEventRepository.mapEventRow({
        'id': 'evt-1',
        'club_id': 'club-1',
        'title': 'Supabase Launch Lab',
        'short_description': 'Connect Flutter to Postgres',
        'description': 'Hands-on session.',
        'category': 'workshops',
        'cover_image_url': 'https://example.com/cover.png',
        'start_at': '2026-12-20T14:00:00Z',
        'end_at': '2026-12-20T16:00:00Z',
        'venue': 'N-Block 201',
        'registration_mode': 'basic',
        'capacity': 100,
        'registration_deadline': '2026-12-19T23:59:00Z',
        'eligibility': 'All Bennett Students',
        'is_team_event': false,
        'status': 'published',
        'published_at': '2026-12-01T10:00:00Z',
        'clubs': {'id': 'club-1', 'name': 'GDG on Campus'},
        'registrations': [
          {'status': 'confirmed'},
          {'status': 'cancelled'},
        ],
      });

      expect(event.id, 'evt-1');
      expect(event.clubName, 'GDG on Campus');
      expect(event.registeredCount, 1);
      expect(event.spotsRemaining, 99);
      expect(event.registrationMode, RegistrationMode.basic);
    });
  });
}
