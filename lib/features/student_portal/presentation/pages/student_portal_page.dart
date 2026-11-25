import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Placeholder page for the Student Portal experience (Stage 0 foundation).
class StudentPortalPage extends StatelessWidget {
  const StudentPortalPage({super.key});

  static const List<({IconData icon, String title, String description})>
  _plannedCapabilities = [
    (
      icon: Icons.event_available_rounded,
      title: 'Campus Event Discovery',
      description:
          'Browse upcoming workshops, hackathons, cultural fests, and club sessions across Bennett University.',
    ),
    (
      icon: Icons.groups_2_outlined,
      title: 'Clubs & Chapters Directory',
      description:
          'Explore onboarded technical, cultural, and sports societies with verified campus leadership.',
    ),
    (
      icon: Icons.confirmation_number_outlined,
      title: 'Registrations & Passes',
      description:
          'Answer custom event questions, manage active registrations, and access entry tickets.',
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
            _PortalBadge(
              label: 'STUDENT PORTAL',
              accentColor: AppColors.secondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Campus life at Bennett, centralized.',
              style: isCompact
                  ? theme.textTheme.headlineLarge
                  : theme.textTheme.displaySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Text(
                'Stage 0 foundation is active. Authentication, club discovery, and event feeds will connect in upcoming stages.',
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
                  label: 'Open Organizer Studio',
                  leadingIcon: Icons.dashboard_customize_outlined,
                  onPressed: () => context.go(AppRoutes.organizerStudio),
                ),
                AppButton(
                  label: 'Microsoft OAuth (Pending)',
                  variant: AppButtonVariant.outline,
                  leadingIcon: Icons.lock_outline_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Authentication will be wired once Supabase is configured.',
                        ),
                      ),
                    );
                  },
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
                  children: _plannedCapabilities.map((item) {
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
                                color: AppColors.primaryMuted,
                                borderRadius: AppRadii.borderMd,
                              ),
                              child: Icon(
                                item.icon,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              item.title,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              item.description,
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
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              elevated: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Design System & Input Preview',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Reusable form controls and feedback components are ready for upcoming feature modules.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: const AppTextField(
                      label: 'Search Preview',
                      hintText: 'Search events, clubs, or campus venues...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.textMuted,
                      ),
                    ),
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

class _PortalBadge extends StatelessWidget {
  const _PortalBadge({required this.label, required this.accentColor});

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.14),
        borderRadius: AppRadii.borderPill,
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: accentColor,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
