import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bennett_campus/features/auth/domain/models/student_user.dart';
import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';

/// Immutable UI authentication state (mocked in Stage 1).
class AuthState {
  const AuthState({
    this.user,
    this.isSigningIn = false,
  });

  final StudentUser? user;
  final bool isSigningIn;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    StudentUser? user,
    bool clearUser = false,
    bool? isSigningIn,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isSigningIn: isSigningIn ?? this.isSigningIn,
    );
  }
}

/// Manages mock Microsoft OAuth sign-in and sign-out for Stage 1.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> signInWithMicrosoft() async {
    if (state.isSigningIn) return;
    state = state.copyWith(isSigningIn: true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    state = const AuthState(
      user: MockCampusData.currentStudent,
      isSigningIn: false,
    );
  }

  void signOut() {
    state = const AuthState();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
