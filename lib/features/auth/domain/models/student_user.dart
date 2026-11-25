/// Represents an authenticated Bennett University student in the UI layer.
class StudentUser {
  const StudentUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.program,
    required this.batchYear,
    required this.initials,
    this.avatarUrl,
    this.authorizedClubIds = const [],
  });

  final String id;
  final String fullName;
  final String email;
  final String program;
  final String batchYear;
  final String initials;
  final String? avatarUrl;
  final List<String> authorizedClubIds;

  String get firstName => fullName.split(' ').first;

  bool get isOrganizer => authorizedClubIds.isNotEmpty;

  StudentUser copyWith({List<String>? authorizedClubIds}) {
    return StudentUser(
      id: id,
      fullName: fullName,
      email: email,
      program: program,
      batchYear: batchYear,
      initials: initials,
      avatarUrl: avatarUrl,
      authorizedClubIds: authorizedClubIds ?? this.authorizedClubIds,
    );
  }
}
