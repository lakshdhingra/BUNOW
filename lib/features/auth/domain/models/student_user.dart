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
  });

  final String id;
  final String fullName;
  final String email;
  final String program;
  final String batchYear;
  final String initials;
  final String? avatarUrl;

  String get firstName => fullName.split(' ').first;
}
