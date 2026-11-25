import 'package:bennett_campus/features/auth/domain/models/student_user.dart';
import 'package:bennett_campus/features/auth/domain/repositories/profile_repository.dart';
import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';

/// Mock implementation of [ProfileRepository] used in isolated widget/unit tests.
class MockProfileRepository implements ProfileRepository {
  @override
  Future<StudentUser?> fetchProfileById(String userId) async {
    if (userId == MockCampusData.currentStudent.id) {
      return MockCampusData.currentStudent;
    }
    return MockCampusData.currentStudent;
  }
}
