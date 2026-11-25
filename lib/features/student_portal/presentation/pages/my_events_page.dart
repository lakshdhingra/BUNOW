import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';
import 'package:bennett_campus/features/student_portal/presentation/providers/student_portal_providers.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/category_chip.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

enum _MyEventsTab {
  upcoming('Upcoming'),
  completed('Completed'),
  cancelled('Cancelled'),
  history('Registration History');

  const _MyEventsTab(this.label);
  final String label;
}

/// Student registrations hub showing upcoming, completed, cancelled, and full history.
class MyEventsPage extends ConsumerStatefulWidget {
  const MyEventsPage({super.key});

  @override
  ConsumerState<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends ConsumerState<MyEventsPage> {
  _MyEventsTab _selectedTab = _MyEventsTab.upcoming;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final registrationsAsync = ref.watch(registrationsControllerProvider);

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Events', style: theme.textTheme.headlineLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Manage upcoming passes, completed campus activities, cancelled entries, and full registration history.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _MyEventsTab.values.map((tab) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: CategoryChip(
                      label: tab.label,
                      isSelected: _selectedTab == tab,
                      onTap: () => setState(() => _selectedTab = tab),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            registrationsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: AppLoadingIndicator(
                  message: 'Loading your registrations...',
                ),
              ),
              error: (error, _) => AppErrorWidget(
                message: error.toString(),
                onRetry: () => ref.invalidate(registrationsControllerProvider),
              ),
              data: (registrations) {
                final filtered = switch (_selectedTab) {
                  _MyEventsTab.upcoming => registrations
                      .where((r) => r.status == RegistrationStatus.confirmed)
                      .toList(),
                  _MyEventsTab.completed => registrations
                      .where((r) => r.status == RegistrationStatus.completed)
                      .toList(),
                  _MyEventsTab.cancelled => registrations
                      .where((r) => r.status == RegistrationStatus.cancelled)
                      .toList(),
                  _MyEventsTab.history => registrations,
                };

                if (filtered.isEmpty) {
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.confirmation_number_outlined,
                          size: 32,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'No ${_selectedTab.label.toLowerCase()} records',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Explore upcoming Bennett campus events to reserve your pass.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppButton(
                          label: 'Explore Events',
                          onPressed: () => context.go(AppRoutes.explore),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: filtered.map((reg) {
                    final event = MockCampusData.events
                        .where((e) => e.id == reg.eventId)
                        .firstOrNull;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _RegistrationRecordCard(
                        registration: reg,
                        event: event,
                        onOpenEvent: event == null
                            ? null
                            : () => context.go(AppRoutes.eventDetail(event.id)),
                        onOpenTicket: () =>
                            context.go(AppRoutes.ticketDetail(reg.id)),
                        onCancel: reg.status == RegistrationStatus.confirmed
                            ? () => _cancelRegistration(context, reg, event)
                            : null,
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

  Future<void> _cancelRegistration(
    BuildContext context,
    EventRegistration reg,
    CampusEvent? event,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Registration?'),
        content: Text(
          'Cancel your spot for ${event?.title ?? 'this event'} (${reg.ticketCode})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep Pass'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancel Pass'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref
        .read(registrationsControllerProvider.notifier)
        .cancelRegistration(reg.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cancelled registration for ${event?.title ?? 'event'}.'),
      ),
    );
  }
}

class _RegistrationRecordCard extends StatelessWidget {
  const _RegistrationRecordCard({
    required this.registration,
    required this.event,
    required this.onOpenEvent,
    required this.onOpenTicket,
    this.onCancel,
  });

  final EventRegistration registration;
  final CampusEvent? event;
  final VoidCallback? onOpenEvent;
  final VoidCallback onOpenTicket;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = DeviceScreenType.of(context) == DeviceScreenType.mobile;
    final statusColor = switch (registration.status) {
      RegistrationStatus.confirmed => AppColors.success,
      RegistrationStatus.completed => AppColors.secondary,
      RegistrationStatus.cancelled => AppColors.error,
    };

    final eventDate = event != null
        ? DateFormat('EEE, d MMM yyyy · h:mm a').format(event!.startTime)
        : 'Date unavailable';
    final registeredDate = DateFormat(
      'd MMM yyyy, h:mm a',
    ).format(registration.registeredAt);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMobile && event != null) ...[
                CampusNetworkImage(
                  imageUrl: event!.bannerUrl,
                  width: 112,
                  height: 84,
                  borderRadius: AppRadii.borderMd,
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.16),
                            borderRadius: AppRadii.borderPill,
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.45),
                            ),
                          ),
                          child: Text(
                            registration.status.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusColor,
                            ),
                          ),
                        ),
                        Text(
                          'Ticket ${registration.ticketCode}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      event?.title ?? 'Campus Event',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${event?.clubName ?? 'Bennett University'} · $eventDate',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      registration.status == RegistrationStatus.cancelled &&
                              registration.cancelledAt != null
                          ? 'Registered $registeredDate · Cancelled ${DateFormat('d MMM').format(registration.cancelledAt!)}'
                          : 'Registered on $registeredDate',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              AppButton(
                label: registration.status == RegistrationStatus.cancelled
                    ? 'View Record'
                    : 'View Ticket',
                variant: AppButtonVariant.primary,
                size: AppButtonSize.sm,
                leadingIcon: Icons.confirmation_number_outlined,
                onPressed: onOpenTicket,
              ),
              if (onOpenEvent != null)
                AppButton(
                  label: 'Event Details',
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.sm,
                  onPressed: onOpenEvent,
                ),
              if (onCancel != null)
                AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.ghost,
                  size: AppButtonSize.sm,
                  onPressed: onCancel,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
