import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:bennett_campus/core/services/supabase_service.dart';
import 'package:bennett_campus/features/auth/data/repositories/mock_profile_repository.dart';
import 'package:bennett_campus/features/auth/data/repositories/supabase_profile_repository.dart';
import 'package:bennett_campus/features/auth/domain/models/student_user.dart';
import 'package:bennett_campus/features/auth/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  if (SupabaseService.isInitialized) {
    return SupabaseProfileRepository(SupabaseService.client);
  }
  return MockProfileRepository();
});

/// Immutable authentication state synced with Supabase Auth & `profiles`.
class AuthState {
  const AuthState({
    this.user,
    this.isSubmitting = false,
    this.isProfileLoading = false,
    this.errorMessage,
    this.infoMessage,
  });

  final StudentUser? user;
  final bool isSubmitting;
  final bool isProfileLoading;
  final String? errorMessage;
  final String? infoMessage;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    StudentUser? user,
    bool clearUser = false,
    bool? isSubmitting,
    bool? isProfileLoading,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }
}

/// Manages Email/Password Supabase Auth, session persistence, and profile loading.
class AuthController extends Notifier<AuthState> {
  StreamSubscription<sb.AuthState>? _authSubscription;

  @override
  AuthState build() {
    if (!SupabaseService.isInitialized) {
      return const AuthState();
    }

    _authSubscription?.cancel();
    _authSubscription = SupabaseService.auth.onAuthStateChange.listen((data) {
      final sessionUser = data.session?.user;
      if (sessionUser == null) {
        state = const AuthState();
      } else {
        unawaited(_loadProfileForAuthUser(sessionUser));
      }
    });
    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    final currentUser = SupabaseService.currentUser;
    if (currentUser != null) {
      Future.microtask(() => _loadProfileForAuthUser(currentUser));
      return AuthState(
        user: _fallbackUser(currentUser),
        isProfileLoading: true,
      );
    }

    return const AuthState();
  }

  StudentUser _fallbackUser(sb.User authUser) {
    final metaName = authUser.userMetadata?['full_name']?.toString();
    return StudentUser.fallbackFromAuth(
      id: authUser.id,
      email: authUser.email ?? '',
      fullName: metaName,
    );
  }

  Future<void> _loadProfileForAuthUser(sb.User authUser) async {
    state = state.copyWith(
      user: state.user?.id == authUser.id
          ? state.user
          : _fallbackUser(authUser),
      isProfileLoading: true,
      clearError: true,
    );

    try {
      final profile = await ref
          .read(profileRepositoryProvider)
          .fetchProfileById(authUser.id);
      state = state.copyWith(
        user: profile ?? _fallbackUser(authUser),
        isProfileLoading: false,
      );
    } catch (_) {
      // Keep authenticated session usable even if profile query fails.
      state = state.copyWith(
        user: _fallbackUser(authUser),
        isProfileLoading: false,
      );
    }
  }

  Future<void> refreshProfile() async {
    final current = SupabaseService.currentUser;
    if (current == null) return;
    await _loadProfileForAuthUser(current);
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (state.isSubmitting) return;
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearInfo: true,
    );

    if (!SupabaseService.isInitialized) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Supabase is not initialized.',
      );
      return;
    }

    try {
      final response = await SupabaseService.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user != null) {
        await _loadProfileForAuthUser(user);
      }
      state = state.copyWith(isSubmitting: false);
    } on sb.AuthException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Unable to sign in right now. Please try again.',
      );
    }
  }

  Future<void> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (state.isSubmitting) return;
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearInfo: true,
    );

    if (!SupabaseService.isInitialized) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Supabase is not initialized.',
      );
      return;
    }

    try {
      final response = await SupabaseService.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim()},
      );
      if (response.session != null && response.user != null) {
        await _loadProfileForAuthUser(response.user!);
        state = state.copyWith(isSubmitting: false);
      } else {
        state = state.copyWith(
          isSubmitting: false,
          infoMessage:
              'Account created. Check your inbox to confirm your email before signing in.',
        );
      }
    } on sb.AuthException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Unable to create account right now. Please try again.',
      );
    }
  }

  Future<void> signOut() async {
    if (SupabaseService.isInitialized) {
      await SupabaseService.auth.signOut();
    }
    state = const AuthState();
  }

  /// Preview helper retained for non-production UI role state checks.
  void toggleMockOrganizerAccess() {
    final user = state.user;
    if (user == null) return;
    final nextClubs = user.isOrganizer
        ? const <String>[]
        : const <String>['preview-club'];
    state = state.copyWith(
      user: user.copyWith(authorizedClubIds: nextClubs),
    );
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
