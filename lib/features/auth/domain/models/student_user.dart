/// Represents an authenticated Bennett University student mapped from `profiles`.
class StudentUser {
  const StudentUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.program,
    required this.batchYear,
    required this.initials,
    this.enrollmentNumber,
    this.department,
    this.yearOfStudy,
    this.avatarUrl,
    this.interests = const [],
    this.onboardingCompleted = false,
    this.isProfileMissing = false,
    this.authorizedClubIds = const [],
  });

  final String id;
  final String fullName;
  final String email;
  final String program;
  final String batchYear;
  final String initials;
  final String? enrollmentNumber;
  final String? department;
  final int? yearOfStudy;
  final String? avatarUrl;
  final List<String> interests;
  final bool onboardingCompleted;
  final bool isProfileMissing;
  final List<String> authorizedClubIds;

  String get firstName => fullName.trim().isEmpty
      ? 'Student'
      : fullName.trim().split(RegExp(r'\s+')).first;

  bool get isOrganizer => authorizedClubIds.isNotEmpty;

  factory StudentUser.fromProfileMap(
    Map<String, dynamic> map, {
    List<String> authorizedClubIds = const [],
  }) {
    final fullName = (map['full_name'] as String?)?.trim();
    final email = (map['email'] as String?)?.trim() ?? '';
    final department = (map['department'] as String?)?.trim();
    final yearOfStudy = (map['year_of_study'] as num?)?.toInt();
    final enrollment = (map['enrollment_number'] as String?)?.trim();
    final resolvedName = (fullName != null && fullName.isNotEmpty)
        ? fullName
        : _nameFromEmail(email);

    final rawInterests = map['interests'];
    final interests = rawInterests is List
        ? rawInterests.map((e) => e.toString()).toList()
        : const <String>[];

    return StudentUser(
      id: map['id'].toString(),
      fullName: resolvedName,
      email: email,
      program: (department != null && department.isNotEmpty)
          ? department
          : 'Bennett University',
      batchYear: yearOfStudy != null
          ? 'Year $yearOfStudy'
          : (enrollment ?? 'Student'),
      initials: _computeInitials(resolvedName),
      enrollmentNumber: enrollment,
      department: department,
      yearOfStudy: yearOfStudy,
      avatarUrl: map['avatar_url'] as String?,
      interests: interests,
      onboardingCompleted: map['onboarding_completed'] == true,
      isProfileMissing: false,
      authorizedClubIds: authorizedClubIds,
    );
  }

  factory StudentUser.fallbackFromAuth({
    required String id,
    required String email,
    String? fullName,
    List<String> authorizedClubIds = const [],
  }) {
    final resolvedName = (fullName != null && fullName.trim().isNotEmpty)
        ? fullName.trim()
        : _nameFromEmail(email);
    return StudentUser(
      id: id,
      fullName: resolvedName,
      email: email,
      program: 'Profile not set up',
      batchYear: 'Bennett University',
      initials: _computeInitials(resolvedName),
      isProfileMissing: true,
      authorizedClubIds: authorizedClubIds,
    );
  }

  StudentUser copyWith({List<String>? authorizedClubIds}) {
    return StudentUser(
      id: id,
      fullName: fullName,
      email: email,
      program: program,
      batchYear: batchYear,
      initials: initials,
      enrollmentNumber: enrollmentNumber,
      department: department,
      yearOfStudy: yearOfStudy,
      avatarUrl: avatarUrl,
      interests: interests,
      onboardingCompleted: onboardingCompleted,
      isProfileMissing: isProfileMissing,
      authorizedClubIds: authorizedClubIds ?? this.authorizedClubIds,
    );
  }

  static String _nameFromEmail(String email) {
    final local = email.split('@').first;
    return local.isEmpty ? 'Bennett Student' : local;
  }

  static String _computeInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'BU';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
