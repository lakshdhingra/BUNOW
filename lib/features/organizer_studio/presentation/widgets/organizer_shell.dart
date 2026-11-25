import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bennett_campus/core/constants/app_constants.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/auth/presentation/providers/auth_provider.dart';
import 'package:bennett_campus/features/organizer_studio/presentation/providers/organizer_providers.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

class _OrganizerDestination {
  const _OrganizerDestination({
    required this.label,
    required this.route,
    required this.icon,
    required this.selectedIcon,
    this.showInMobileBar = true,
  });

  final String label;
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final bool showInMobileBar;
}

/// Adaptive navigation shell dedicated to BENNETT Organizer Studio.
class OrganizerShell extends ConsumerStatefulWidget {
  const OrganizerShell({
    super.key,
    required this.currentLocation,
    required this.child,
  });

  final String currentLocation;
  final Widget child;

  @override
  ConsumerState<OrganizerShell> createState() => _OrganizerShellState();
}

class _OrganizerShellState extends ConsumerState<OrganizerShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<_OrganizerDestination> _destinations = [
    _OrganizerDestination(
      label: 'Dashboard',
      route: AppRoutes.organizerDashboard,
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights_rounded,
    ),
    _OrganizerDestination(
      label: 'Events',
      route: AppRoutes.organizerEvents,
      icon: Icons.event_note_outlined,
      selectedIcon: Icons.event_note_rounded,
    ),
    _OrganizerDestination(
      label: 'Create Event',
      route: AppRoutes.organizerNewEvent,
      icon: Icons.add_box_outlined,
      selectedIcon: Icons.add_box_rounded,
      showInMobileBar: false,
    ),
    _OrganizerDestination(
      label: 'Registrations',
      route: AppRoutes.organizerRegistrations,
      icon: Icons.people_alt_outlined,
      selectedIcon: Icons.people_alt_rounded,
    ),
    _OrganizerDestination(
      label: 'Club Settings',
      route: AppRoutes.organizerClub,
      icon: Icons.shield_outlined,
      selectedIcon: Icons.shield_rounded,
    ),
  ];

  int get _selectedIndex {
    if (widget.currentLocation.startsWith(AppRoutes.organizerNewEvent) ||
        widget.currentLocation.contains('/edit')) {
      return 2;
    }
    final idx = _destinations.indexWhere(
      (d) => widget.currentLocation.startsWith(d.route),
    );
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final clubs = ref.watch(authorizedClubsProvider).value ?? const [];
    final activeClub = ref.watch(activeOrganizerClubProvider);
    final screenType = DeviceScreenType.of(context);

    if (user == null || !user.isOrganizer) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: AppCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.warningMuted,
                        borderRadius: AppRadii.borderMd,
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Organizer Access Restricted',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'This workspace is reserved for authorized Bennett University club representatives. Final permission enforcement will run via Supabase RLS policies.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        AppButton(
                          label: 'Back to Student Portal',
                          onPressed: () => context.go(AppRoutes.home),
                        ),
                        AppButton(
                          label: 'Enable Mock Rep Preview',
                          variant: AppButtonVariant.outline,
                          onPressed: () => ref
                              .read(authControllerProvider.notifier)
                              .toggleMockOrganizerAccess(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final topBar = _OrganizerTopBar(
      clubs: clubs,
      activeClub: activeClub,
      isMobile: screenType == DeviceScreenType.mobile,
      onClubSelected: (clubId) {
        ref.read(selectedOrganizerClubIdProvider.notifier).select(clubId);
      },
      onOpenDrawer: screenType == DeviceScreenType.mobile
          ? () => _scaffoldKey.currentState?.openDrawer()
          : null,
      onCreateEvent: () => context.go(AppRoutes.organizerNewEvent),
      onExitStudio: () => context.go(AppRoutes.home),
    );

    final bodyColumn = Column(
      children: [
        topBar,
        Expanded(child: widget.child),
      ],
    );

    final selectedIndex = _selectedIndex;

    return switch (screenType) {
      DeviceScreenType.desktop => Scaffold(
        body: Row(
          children: [
            _OrganizerSidebar(
              selectedIndex: selectedIndex,
              destinations: _destinations,
              onSelect: (index) => context.go(_destinations[index].route),
              onExitStudio: () => context.go(AppRoutes.home),
            ),
            Expanded(child: bodyColumn),
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
                          context.go(_destinations[index].route),
                      labelType: NavigationRailLabelType.all,
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        child: IconButton(
                          tooltip: 'Back to Student Portal',
                          onPressed: () => context.go(AppRoutes.home),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
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
            Expanded(child: bodyColumn),
          ],
        ),
      ),
      DeviceScreenType.mobile => _buildMobileScaffold(
        context,
        bodyColumn,
        selectedIndex,
      ),
    };
  }

  Widget _buildMobileScaffold(
    BuildContext context,
    Widget bodyColumn,
    int selectedIndex,
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
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadii.borderSm,
                      ),
                      child: const Icon(
                        Icons.dashboard_customize_rounded,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Organizer Studio',
                        style: Theme.of(context).textTheme.titleMedium,
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
                      title: Text(item.label),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go(item.route);
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.explore_outlined),
                title: const Text('Switch to Student Portal'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(AppRoutes.home);
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(bottom: false, child: bodyColumn),
      bottomNavigationBar: NavigationBar(
        selectedIndex: mobileIndex < 0 ? 0 : mobileIndex,
        onDestinationSelected: (i) => context.go(mobileDestinations[i].route),
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

class _OrganizerSidebar extends StatelessWidget {
  const _OrganizerSidebar({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelect,
    required this.onExitStudio,
  });

  final int selectedIndex;
  final List<_OrganizerDestination> destinations;
  final ValueChanged<int> onSelect;
  final VoidCallback onExitStudio;

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
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadii.borderSm,
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.45),
                    ),
                  ),
                  child: const Icon(
                    Icons.dashboard_customize_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
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
                        'Organizer Studio',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.secondary,
                        ),
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
            child: Text('CLUB OPERATIONS', style: theme.textTheme.labelSmall),
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
            child: AppButton(
              label: 'Student Portal',
              variant: AppButtonVariant.outline,
              size: AppButtonSize.sm,
              leadingIcon: Icons.explore_outlined,
              fullWidth: true,
              onPressed: onExitStudio,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganizerTopBar extends StatelessWidget {
  const _OrganizerTopBar({
    required this.clubs,
    required this.activeClub,
    required this.isMobile,
    required this.onClubSelected,
    required this.onCreateEvent,
    required this.onExitStudio,
    this.onOpenDrawer,
  });

  final List<CampusClub> clubs;
  final CampusClub? activeClub;
  final bool isMobile;
  final ValueChanged<String> onClubSelected;
  final VoidCallback onCreateEvent;
  final VoidCallback onExitStudio;
  final VoidCallback? onOpenDrawer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          if (isMobile && onOpenDrawer != null) ...[
            IconButton(
              tooltip: 'Organizer menu',
              onPressed: onOpenDrawer,
              icon: const Icon(Icons.menu_rounded),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          if (clubs.isNotEmpty && activeClub != null)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 290),
                  child: DropdownButtonFormField<String>(
                    initialValue: activeClub!.id,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceElevated,
                    style: theme.textTheme.titleSmall,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm + 2,
                        vertical: AppSpacing.xs + 2,
                      ),
                      prefixIcon: const Icon(
                        Icons.groups_2_outlined,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: AppRadii.borderMd,
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: AppRadii.borderMd,
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                    items: clubs
                        .map(
                          (club) => DropdownMenuItem<String>(
                            value: club.id,
                            child: Text(
                              club.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onClubSelected(value);
                    },
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: AppSpacing.sm),
          if (!isMobile)
            AppButton(
              label: 'New Event',
              size: AppButtonSize.sm,
              leadingIcon: Icons.add_rounded,
              onPressed: onCreateEvent,
            )
          else
            IconButton(
              tooltip: 'Create Event',
              onPressed: onCreateEvent,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
              ),
              icon: const Icon(Icons.add_rounded, size: 20),
            ),
        ],
      ),
    );
  }
}
