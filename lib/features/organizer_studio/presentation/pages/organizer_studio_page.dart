import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Placeholder page for the Organizer Studio experience (Stage 0 foundation).
class OrganizerStudioPage extends StatelessWidget {
  const OrganizerStudioPage({super.key});

  static const List<({IconData icon, String title, String description})>
  _studioModules = [
    (
      icon: Icons.add_box_outlined,
      title: 'Event Authoring & Publishing',
      description:
          'Create, edit, and publish events for clubs you are explicitly authorized to manage.',
    ),
    (
      icon: Icons.assignment_outlined,
      title: 'Custom Registration Forms',
      description:
          'Collect structured participant responses, review registrations, and export rosters.',
    ),
    (
      icon: Icons.qr_code_scanner_rounded,
      title: 'Attendance & Club Permissions',
      description:
          'Track check-ins and manage club profiles and representative access securely.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenType = DeviceScreenType.of(context);
    final isCompact = screenType == DeviceScreenType.mobile;

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryMuted,
                borderRadius: AppRadii.borderPill,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'ORGANIZER STUDIO',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.primaryHover,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Club operations & event studio.',
              style: isCompact
                  ? theme.textTheme.headlineLarge
                  : theme.textTheme.displaySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Text(
                'This workspace is reserved for authorized Bennett club representatives. Role checks and RLS policies will enforce access server-side in upcoming stages.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppButton(
                  label: 'Back to Student Portal',
                  variant: AppButtonVariant.secondary,
                  leadingIcon: Icons.explore_outlined,
                  onPressed: () => context.go(AppRoutes.studentPortal),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = switch (screenType) {
                  DeviceScreenType.desktop => 3,
                  DeviceScreenType.tablet => 2,
                  DeviceScreenType.mobile => 1,
                };
                final itemWidth =
                    (constraints.maxWidth - AppSpacing.md * (columns - 1)) /
                    columns;

                return Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: _studioModules.map((module) {
                    return SizedBox(
                      width: itemWidth,
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppColors.secondaryMuted,
                                borderRadius: AppRadii.borderMd,
                              ),
                              child: Icon(
                                module.icon,
                                color: AppColors.secondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              module.title,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              module.description,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
