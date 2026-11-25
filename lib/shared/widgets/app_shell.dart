import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bennett_campus/core/constants/app_constants.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/auth/presentation/providers/auth_provider.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/student_top_bar.dart';
import 'package:bennett_campus/shared/widgets/app_button.dart';
import 'package:bennett_campus/shared/widgets/responsive_layout.dart';

class _NavDestination {
  const _NavDestination({
    required this.label,
    required this.route,
    required this.icon,
    required this.selectedIcon,
    this.showInMobileBar = false,
  });

  final String label;
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final bool showInMobileBar;
}

/// Adaptive navigation shell for the BENNETT Student Portal.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    super.key,
    required this.currentLocation,
    required this.child,
  });

  final String currentLocation;
  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<_NavDestination> _destinations = [
    _NavDestination(
      label: 'Home',
      route: AppRoutes.home,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      showInMobileBar: true,
    ),
    _NavDestination(
      label: 'Explore',
      route: AppRoutes.explore,
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore_rounded,
      showInMobileBar: true,
    ),
    _NavDestination(
      label: 'Calendar',
      route: AppRoutes.calendar,
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
      showInMobileBar: true,
    ),
    _NavDestination(
      label: 'My Events',
      route: AppRoutes.myEvents,
      icon: Icons.confirmation_number_outlined,
      selectedIcon: Icons.confirmation_number_rounded,
      showInMobileBar: true,
    ),
    _NavDestination(
      label: 'Clubs',
      route: AppRoutes.clubs,
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups_rounded,
      showInMobileBar: true,
    ),
    _NavDestination(
      label: 'Highlights',
      route: AppRoutes.highlights,
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome_rounded,
    ),
    _NavDestination(
      label: 'Notifications',
      route: AppRoutes.notifications,
      icon: Icons.notifications_none_rounded,
      selectedIcon: Icons.notifications_rounded,
    ),
    _NavDestination(
      label: 'Profile',
      route: AppRoutes.profile,
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  int get _selectedIndex {
    if (widget.currentLocation.startsWith('/events/')) {
      return 1;
    }
    if (widget.currentLocation.startsWith('/tickets/')) {
      return 3;
    }
    final index = _destinations.indexWhere(
      (item) => widget.currentLocation.startsWith(item.route),
    );
    return index < 0 ? 0 : index;
  }

  void _navigateTo(String route) {
    if (widget.currentLocation != route) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenType = DeviceScreenType.of(context);
    final selectedIndex = _selectedIndex;
    final user = ref.watch(authControllerProvider).user;

    final contentColumn = Column(
      children: [
        StudentTopBar(
          currentLocation: widget.currentLocation,
          onOpenMobileDrawer: screenType == DeviceScreenType.mobile
              ? () => _scaffoldKey.currentState?.openDrawer()
              : null,
        ),
        Expanded(child: widget.child),
      ],
    );

    return switch (screenType) {
      DeviceScreenType.desktop => Scaffold(
        body: Row(
          children: [
            _DesktopSidebar(
              selectedIndex: selectedIndex,
              destinations: _destinations,
              studentName: user?.fullName ?? 'Bennett Student',
              studentEmail: user?.email ?? 'student@bennett.edu.in',
              showOrganizerEntry: user?.isOrganizer ?? false,
              onOpenOrganizer: () => context.go(AppRoutes.organizerDashboard),
              onSelect: (index) => _navigateTo(_destinations[index].route),
            ),
            Expanded(child: contentColumn),
          ],
        ),
      ),
      DeviceScreenType.tablet => Scaffold(
        body: Row(
          children: [
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: NavigationRail(
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (index) =>
                          _navigateTo(_destinations[index].route),
                      labelType: NavigationRailLabelType.all,
                      leading: const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: _BrandMark(),
                      ),
                      destinations: _destinations
                          .map(
                            (d) => NavigationRailDestination(
                              icon: Icon(d.icon),
                              selectedIcon: Icon(d.selectedIcon),
                              label: Text(d.label),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: contentColumn),
          ],
        ),
      ),
      DeviceScreenType.mobile => _buildMobileScaffold(
        context,
        contentColumn,
        selectedIndex,
        user?.fullName ?? 'Bennett Student',
        user?.email ?? 'student@bennett.edu.in',
      ),
    };
  }

  Widget _buildMobileScaffold(
    BuildContext context,
    Widget contentColumn,
    int selectedIndex,
    String studentName,
    String studentEmail,
  ) {
    final mobileDestinations = _destinations
        .where((d) => d.showInMobileBar)
        .toList();
    final activeRoute = _destinations[selectedIndex].route;
    final mobileIndex = mobileDestinations.indexWhere(
      (d) => d.route == activeRoute,
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    const _BrandMark(),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            studentEmail,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  itemCount: _destinations.length,
                  itemBuilder: (context, index) {
                    final item = _destinations[index];
                    final isSelected = index == selectedIndex;
                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: AppColors.primaryMuted,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadii.borderMd,
                      ),
                      leading: Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      title: Text(
                        item.label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _navigateTo(item.route);
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              if (ref.watch(authControllerProvider).user?.isOrganizer ?? false)
                ListTile(
                  leading: const Icon(
                    Icons.dashboard_customize_outlined,
                    color: AppColors.secondary,
                  ),
                  title: const Text('Organizer Studio'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go(AppRoutes.organizerDashboard);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: Text(
                  'Sign out ($studentName)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(authControllerProvider.notifier).signOut();
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(bottom: false, child: contentColumn),
      bottomNavigationBar: NavigationBar(
        selectedIndex: mobileIndex < 0 ? 0 : mobileIndex,
        onDestinationSelected: (i) => _navigateTo(mobileDestinations[i].route),
        destinations: mobileDestinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.selectedIndex,
    required this.destinations,
    required this.studentName,
    required this.studentEmail,
    required this.showOrganizerEntry,
    required this.onOpenOrganizer,
    required this.onSelect,
  });

  final int selectedIndex;
  final List<_NavDestination> destinations;
  final String studentName;
  final String studentEmail;
  final bool showOrganizerEntry;
  final VoidCallback onOpenOrganizer;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: AppSpacing.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const _BrandMark(),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          letterSpacing: 0.9,
                        ),
                      ),
                      Text(
                        AppConstants.universityName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Text('STUDENT PORTAL', style: theme.textTheme.labelSmall),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              itemCount: destinations.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xxs),
              itemBuilder: (context, index) {
                final item = destinations[index];
                final isSelected = index == selectedIndex;

                return Material(
                  color: isSelected
                      ? AppColors.primaryMuted
                      : Colors.transparent,
                  borderRadius: AppRadii.borderMd,
                  child: InkWell(
                    onTap: () => onSelect(index),
                    borderRadius: AppRadii.borderMd,
                    hoverColor: AppColors.surfaceHover.withValues(alpha: 0.4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm + 2,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: AppRadii.borderMd,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.45)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? item.selectedIcon : item.icon,
                            size: 20,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              item.label,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                if (showOrganizerEntry) ...[
                  AppButton(
                    label: 'Organizer Studio',
                    size: AppButtonSize.sm,
                    variant: AppButtonVariant.secondary,
                    leadingIcon: Icons.dashboard_customize_outlined,
                    fullWidth: true,
                    onPressed: onOpenOrganizer,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppRadii.borderMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: theme.textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        studentEmail,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadii.borderSm,
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        'B',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
