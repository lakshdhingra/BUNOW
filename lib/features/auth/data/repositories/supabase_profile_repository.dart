import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bennett_campus/features/auth/domain/models/student_user.dart';
import 'package:bennett_campus/features/auth/domain/repositories/profile_repository.dart';

/// Supabase-backed implementation of [ProfileRepository] reading `profiles` and `club_members`.
class SupabaseProfileRepository implements ProfileRepository {
  const SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  static const String _profileColumns =
      'id, full_name, email, enrollment_number, department, year_of_study, avatar_url, interests, onboarding_completed, created_at, updated_at';

  @override
  Future<StudentUser?> fetchProfileById(String userId) async {
    final profileRow = await _client
        .from('profiles')
        .select(_profileColumns)
        .eq('id', userId)
        .maybeSingle();

    if (profileRow == null) return null;

    final clubRows = await _client
        .from('club_members')
        .select('club_id')
        .eq('user_id', userId)
        .eq('is_active', true);

    final authorizedClubIds = clubRows
        .map((row) => row['club_id']?.toString())
        .whereType<String>()
        .toList();

    return StudentUser.fromProfileMap(
      profileRow,
      authorizedClubIds: authorizedClubIds,
    );
  }
}
