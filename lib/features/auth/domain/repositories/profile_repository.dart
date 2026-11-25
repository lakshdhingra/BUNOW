import 'package:bennett_campus/features/auth/domain/models/student_user.dart';

/// Repository contract for fetching the authenticated user's profile.
abstract interface class ProfileRepository {
  Future<StudentUser?> fetchProfileById(String userId);
}
