import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/features/auth/presentation/pages/login_page.dart';
import 'package:bennett_campus/features/auth/presentation/providers/auth_provider.dart';
import 'package:bennett_campus/features/student_portal/presentation/pages/calendar_page.dart';
import 'package:bennett_campus/features/student_portal/presentation/pages/clubs_page.dart';
import 'package:bennett_campus/features/student_portal/presentation/pages/explore_page.dart';
import 'package:bennett_campus/features/student_portal/presentation/pages/highlights_page.dart';
import 'package:bennett_campus/features/student_portal/presentation/pages/home_page.dart';
import 'package:bennett_campus/features/student_portal/presentation/pages/my_events_page.dart';
import 'package:bennett_campus/features/student_portal/presentation/pages/profile_page.dart';
import 'package:bennett_campus/shared/widgets/app_error_widget.dart';
import 'package:bennett_campus/shared/widgets/app_shell.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

/// Global GoRouter provider wired to Riverpod authentication state.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref.listen<AuthState>(
    authControllerProvider,
    (_, _) => refreshNotifier.refresh(),
  );
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final isAuthenticated = ref.read(authControllerProvider).isAuthenticated;
      final location = state.uri.path;
      final isLoggingIn = location == AppRoutes.login;

      if (!isAuthenticated) {
        return isLoggingIn ? null : AppRoutes.login;
      }

      if (isLoggingIn || location == AppRoutes.root) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginPage(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(
            currentLocation: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.explore,
            name: 'explore',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ExplorePage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.calendar,
            name: 'calendar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.myEvents,
            name: 'my_events',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MyEventsPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.clubs,
            name: 'clubs',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ClubsPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.highlights,
            name: 'highlights',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HighlightsPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfilePage(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AppErrorWidget(
          title: 'Page not found',
          message: 'No route matches "${state.uri}".',
          retryLabel: 'Go to Home',
          onRetry: () => context.go(AppRoutes.home),
        ),
      ),
    ),
  );
});
