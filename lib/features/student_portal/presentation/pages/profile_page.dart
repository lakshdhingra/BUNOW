import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/auth/presentation/providers/auth_provider.dart';
import 'package:bennett_campus/features/student_portal/presentation/providers/student_portal_providers.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Student profile and account overview placeholder page (Stage 1).
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final registeredCount = ref.watch(registeredEventIdsProvider).length;

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student Profile', style: theme.textTheme.headlineLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Your Bennett University identity and activity summary.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (user != null && user.isProfileMissing) ...[
              AppCard(
                borderColor: AppColors.warning.withValues(alpha: 0.45),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile record not found in Supabase',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Signed in as ${user.email}, but no matching row exists in `profiles` for UID ${user.id} yet.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppButton(
                      label: 'Retry',
                      size: AppButtonSize.sm,
                      variant: AppButtonVariant.outline,
                      isLoading: authState.isProfileLoading,
                      onPressed: () => ref
                          .read(authControllerProvider.notifier)
                          .refreshProfile(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.initials ?? 'BU',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'Bennett Student',
                          style: theme.textTheme.headlineSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user?.email ?? 'student@bennett.edu.in',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.secondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (user?.enrollmentNumber != null &&
                                user!.enrollmentNumber!.isNotEmpty)
                              user.enrollmentNumber!,
                            user?.program ?? 'Bennett University',
                            user?.batchYear ?? '',
                          ].where((s) => s.isNotEmpty).join(' · '),
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user != null && user.interests.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: user.interests
                                .map((tag) => Chip(label: Text(tag)))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (DeviceScreenType.of(context) != DeviceScreenType.mobile) ...[
                    const SizedBox(width: AppSpacing.md),
                    AppButton(
                      label: 'Sign out',
                      variant: AppButtonVariant.outline,
                      leadingIcon: Icons.logout_rounded,
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).signOut(),
                    ),
                  ],
                ],
              ),
            ),
            if (DeviceScreenType.of(context) == DeviceScreenType.mobile) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Sign out',
                variant: AppButtonVariant.outline,
                leadingIcon: Icons.logout_rounded,
                fullWidth: true,
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).signOut(),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            ResponsiveCardGrid(
              desktopColumns: 3,
              tabletColumns: 2,
              mobileColumns: 1,
              children: [
                _ProfileShortcutCard(
                  icon: Icons.confirmation_number_outlined,
                  title: 'Registered Events',
                  value: '$registeredCount active passes',
                  onTap: () => context.go(AppRoutes.myEvents),
                ),
                _ProfileShortcutCard(
                  icon: Icons.calendar_month_outlined,
                  title: 'Campus Schedule',
                  value: 'View chronological calendar',
                  onTap: () => context.go(AppRoutes.calendar),
                ),
                _ProfileShortcutCard(
                  icon: Icons.auto_awesome_outlined,
                  title: 'Campus Highlights',
                  value: 'Browse event galleries',
                  onTap: () => context.go(AppRoutes.highlights),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              elevated: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryMuted,
                          borderRadius: AppRadii.borderMd,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_outlined,
                          color: AppColors.primaryHover,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Organizer Studio & Role Preview',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              (user?.isOrganizer ?? false)
                                  ? 'This mock student account is authorized for ${user!.authorizedClubIds.length} clubs. Real authorization will be enforced server-side via Supabase RLS.'
                                  : 'Standard student mode active. Toggle mock representative access below to preview Organizer Studio authorization states.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      if (user?.isOrganizer ?? false)
                        AppButton(
                          label: 'Open Organizer Studio',
                          size: AppButtonSize.sm,
                          leadingIcon: Icons.dashboard_customize_outlined,
                          onPressed: () =>
                              context.go(AppRoutes.organizerDashboard),
                        ),
                      AppButton(
                        label: (user?.isOrganizer ?? false)
                            ? 'Preview Standard Student View'
                            : 'Enable Mock Organizer Access',
                        variant: AppButtonVariant.outline,
                        size: AppButtonSize.sm,
                        onPressed: () => ref
                            .read(authControllerProvider.notifier)
                            .toggleMockOrganizerAccess(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileShortcutCard extends StatelessWidget {
  const _ProfileShortcutCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.secondaryMuted,
              borderRadius: AppRadii.borderMd,
            ),
            child: Icon(icon, color: AppColors.secondary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                Text(value, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}
