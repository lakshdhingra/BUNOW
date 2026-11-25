import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bennett_campus/features/student_portal/data/repositories/supabase_event_repository.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/repositories/club_repository.dart';

/// Supabase-backed implementation of [ClubRepository].
class SupabaseClubRepository implements ClubRepository {
  const SupabaseClubRepository(this._client);

  final SupabaseClient _client;

  static const String _clubColumns =
      'id, name, slug, description, category, logo_url, cover_image_url, '
      'instagram_url, linkedin_url, website_url, faculty_coordinator, is_active, '
      'created_at, updated_at';

  @override
  Future<List<CampusClub>> fetchActiveClubs() async {
    final rows = await _client
        .from('clubs')
        .select(_clubColumns)
        .eq('is_active', true)
        .order('name', ascending: true);

    return rows.map((row) => _mapClubRow(row)).toList();
  }

  @override
  Future<CampusClub?> fetchClubById(String clubId) async {
    final row = await _client
        .from('clubs')
        .select(_clubColumns)
        .eq('id', clubId)
        .maybeSingle();

    if (row == null) return null;

    final memberRows = await _client
        .from('club_members')
        .select(
          'id, role, is_active, '
          'profiles!club_members_user_id_fkey(full_name, department, year_of_study)',
        )
        .eq('club_id', clubId)
        .eq('is_active', true);

    final leaders = <ClubLeader>[];
    for (final m in memberRows) {
      final profile = m['profiles'];
      if (profile is! Map<String, dynamic>) continue;
      final fullName = (profile['full_name'] as String?)?.trim() ?? 'Coordinator';
      final dept = (profile['department'] as String?)?.trim() ?? 'Bennett University';
      final year = (profile['year_of_study'] as num?)?.toInt();
      leaders.add(
        ClubLeader(
          name: fullName,
          role: (m['role'] ?? 'Representative').toString(),
          program: year != null ? '$dept · Year $year' : dept,
          initials: _initials(fullName),
        ),
      );
    }

    return _mapClubRow(
      row,
      memberCount: memberRows.length,
      leadership: leaders,
    );
  }

  @override
  Future<List<CampusEvent>> fetchEventsForClub(String clubId) async {
    final rows = await _client
        .from('events')
        .select(
          'id, club_id, created_by, title, slug, short_description, description, '
          'category, cover_image_url, start_at, end_at, venue, registration_mode, '
          'capacity, registration_deadline, eligibility, is_team_event, '
          'min_team_size, max_team_size, status, published_at, created_at, updated_at, '
          'clubs(id, name), registrations(status)',
        )
        .eq('club_id', clubId)
        .inFilter('status', ['published', 'completed'])
        .order('start_at', ascending: true);

    return rows.map((r) => SupabaseEventRepository.mapEventRow(r)).toList();
  }

  static CampusClub _mapClubRow(
    Map<String, dynamic> row, {
    int memberCount = 0,
    List<ClubLeader> leadership = const [],
  }) {
    final name = (row['name'] as String?)?.trim() ?? 'Campus Club';
    final description = (row['description'] as String?)?.trim() ?? '';
    final socialLinks = <ClubSocialLink>[];

    final instagram = (row['instagram_url'] as String?)?.trim() ?? '';
    if (instagram.isNotEmpty) {
      socialLinks.add(
        ClubSocialLink(
          platform: 'Instagram',
          handle: instagram,
          url: instagram,
        ),
      );
    }
    final linkedin = (row['linkedin_url'] as String?)?.trim() ?? '';
    if (linkedin.isNotEmpty) {
      socialLinks.add(
        ClubSocialLink(
          platform: 'LinkedIn',
          handle: linkedin,
          url: linkedin,
        ),
      );
    }
    final website = (row['website_url'] as String?)?.trim() ?? '';
    if (website.isNotEmpty) {
      socialLinks.add(
        ClubSocialLink(
          platform: 'Website',
          handle: website,
          url: website,
        ),
      );
    }

    return CampusClub(
      id: row['id'].toString(),
      name: name,
      shortCode: _initials(name),
      category: (row['category'] as String?)?.trim() ?? 'Campus Club',
      tagline: description,
      about: description,
      memberCount: memberCount,
      upcomingEventCount: 0,
      coverUrl: (row['cover_image_url'] as String?)?.trim() ?? '',
      logoUrl: (row['logo_url'] as String?)?.trim(),
      isVerified: row['is_active'] == true,
      socialLinks: socialLinks,
      leadership: leadership,
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'BU';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
}
