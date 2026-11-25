import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/auth/presentation/providers/auth_provider.dart';
import 'package:bennett_campus/features/student_portal/presentation/providers/student_portal_providers.dart';
import 'package:bennett_campus/shared/widgets/app_search_bar.dart';
import 'package:bennett_campus/shared/widgets/responsive_layout.dart';

/// Top bar with search input, campus notifications button, and student menu.
class StudentTopBar extends ConsumerStatefulWidget {
  const StudentTopBar({
    super.key,
    required this.currentLocation,
    this.onOpenMobileDrawer,
  });

  final String currentLocation;
  final VoidCallback? onOpenMobileDrawer;

  @override
  ConsumerState<StudentTopBar> createState() => _StudentTopBarState();
}

class _StudentTopBarState extends ConsumerState<StudentTopBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final currentQuery = ref.watch(searchQueryProvider);
    if (_searchController.text != currentQuery) {
      _searchController.value = TextEditingValue(
        text: currentQuery,
        selection: TextSelection.collapsed(offset: currentQuery.length),
      );
    }

    final screenType = DeviceScreenType.of(context);
    final isMobile = screenType == DeviceScreenType.mobile;
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.md : AppSpacing.xl,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          if (isMobile && widget.onOpenMobileDrawer != null) ...[
            IconButton(
              tooltip: 'Navigation menu',
              onPressed: widget.onOpenMobileDrawer,
              icon: const Icon(Icons.menu_rounded),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: AppSearchBar(
                  controller: _searchController,
                  hintText: isMobile
                      ? 'Search events or clubs...'
                      : 'Search campus events, clubs, or venues...',
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).update(value);
                  },
                  onSubmitted: (_) {
                    if (widget.currentLocation != AppRoutes.explore) {
                      context.go(AppRoutes.explore);
                    }
                  },
                  onClear: () {
                    ref.read(searchQueryProvider.notifier).clear();
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _NotificationButton(
            unreadCount: unreadCount,
            onPressed: () => context.go(AppRoutes.notifications),
          ),
          const SizedBox(width: AppSpacing.xs),
          _StudentProfileMenu(
            initials: user?.initials ?? 'BU',
            fullName: user?.fullName ?? 'Bennett Student',
            email: user?.email ?? 'student@bennett.edu.in',
            showName: !isMobile,
            onProfileTap: () => context.go(AppRoutes.profile),
            onMyEventsTap: () => context.go(AppRoutes.myEvents),
            onHighlightsTap: () => context.go(AppRoutes.highlights),
            onSignOutTap: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.unreadCount,
    required this.onPressed,
  });

  final int unreadCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.border),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadii.borderMd,
            ),
          ),
          icon: const Icon(
            Icons.notifications_none_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _StudentProfileMenu extends StatelessWidget {
  const _StudentProfileMenu({
    required this.initials,
    required this.fullName,
    required this.email,
    required this.showName,
    required this.onProfileTap,
    required this.onMyEventsTap,
    required this.onHighlightsTap,
    required this.onSignOutTap,
  });

  final String initials;
  final String fullName;
  final String email;
  final bool showName;
  final VoidCallback onProfileTap;
  final VoidCallback onMyEventsTap;
  final VoidCallback onHighlightsTap;
  final VoidCallback onSignOutTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      tooltip: 'Student account menu',
      color: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.borderMd,
        side: BorderSide(color: AppColors.border),
      ),
      onSelected: (value) {
        switch (value) {
          case 'profile':
            onProfileTap();
          case 'my_events':
            onMyEventsTap();
          case 'highlights':
            onHighlightsTap();
          case 'sign_out':
            onSignOutTap();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fullName, style: theme.textTheme.titleSmall),
              Text(email, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 18),
              SizedBox(width: AppSpacing.sm),
              Text('Profile'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'my_events',
          child: Row(
            children: [
              Icon(Icons.confirmation_number_outlined, size: 18),
              SizedBox(width: AppSpacing.sm),
              Text('My Events'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'highlights',
          child: Row(
            children: [
              Icon(Icons.auto_awesome_outlined, size: 18),
              SizedBox(width: AppSpacing.sm),
              Text('Highlights'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'sign_out',
          child: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 18,
                color: AppColors.error,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Sign out',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: showName ? AppSpacing.sm : AppSpacing.xs,
          vertical: AppSpacing.xxs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.borderMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary,
              child: Text(
                initials,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (showName) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                fullName,
                style: theme.textTheme.labelLarge?.copyWith(fontSize: 13),
              ),
              const SizedBox(width: AppSpacing.xxs),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
