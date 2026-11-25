import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/organizer_studio/domain/models/organizer_models.dart';
import 'package:bennett_campus/features/organizer_studio/presentation/providers/organizer_providers.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/category_chip.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

enum _EventManagementFilter {
  all('All Events'),
  draft('Drafts'),
  published('Published'),
  completed('Completed');

  const _EventManagementFilter(this.label);
  final String label;
}

/// Organizer Event Management page with status tabs and edit/duplicate/cancel actions.
class OrganizerEventsPage extends ConsumerStatefulWidget {
  const OrganizerEventsPage({super.key});

  @override
  ConsumerState<OrganizerEventsPage> createState() =>
      _OrganizerEventsPageState();
}

class _OrganizerEventsPageState extends ConsumerState<OrganizerEventsPage> {
  final TextEditingController _searchController = TextEditingController();
  _EventManagementFilter _filter = _EventManagementFilter.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventsAsync = ref.watch(organizerEventsControllerProvider);

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Event Management', style: theme.textTheme.headlineLarge),
                    const SizedBox(height: 2),
                    Text(
                      'Create, edit, duplicate, or cancel events for your assigned club.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                AppButton(
                  label: 'Create Event',
                  leadingIcon: Icons.add_rounded,
                  onPressed: () => context.go(AppRoutes.organizerNewEvent),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AppSearchBar(
                controller: _searchController,
                hintText: 'Search club events by title or venue...',
                onChanged: (value) => setState(() => _query = value),
                onClear: () => setState(() => _query = ''),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _EventManagementFilter.values.map((tab) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: CategoryChip(
                      label: tab.label,
                      isSelected: _filter == tab,
                      onTap: () => setState(() => _filter = tab),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            eventsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: AppLoadingIndicator(message: 'Loading club events...'),
              ),
              error: (error, _) => AppErrorWidget(
                message: error.toString(),
                onRetry: () =>
                    ref.invalidate(organizerEventsControllerProvider),
              ),
              data: (events) {
                final normalized = _query.trim().toLowerCase();
                final filtered = events.where((event) {
                  final matchesTab = switch (_filter) {
                    _EventManagementFilter.all => true,
                    _EventManagementFilter.draft =>
                      event.status == OrganizerEventStatus.draft,
                    _EventManagementFilter.published =>
                      event.status == OrganizerEventStatus.published,
                    _EventManagementFilter.completed =>
                      event.status == OrganizerEventStatus.completed,
                  };
                  if (!matchesTab) return false;
                  if (normalized.isEmpty) return true;
                  return event.title.toLowerCase().contains(normalized) ||
                      event.venue.toLowerCase().contains(normalized);
                }).toList();

                if (filtered.isEmpty) {
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No matching events in ${_filter.label}',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Start a new event draft or switch status filters.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppButton(
                          label: 'Open Event Wizard',
                          size: AppButtonSize.sm,
                          onPressed: () =>
                              context.go(AppRoutes.organizerNewEvent),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: filtered.map((event) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _OrganizerEventRowCard(
                        event: event,
                        onEdit: () => context.go(
                          AppRoutes.organizerEditEvent(event.id),
                        ),
                        onDuplicate: () => _duplicateEvent(event),
                        onCancel: event.status == OrganizerEventStatus.cancelled ||
                                event.status == OrganizerEventStatus.completed
                            ? null
                            : () => _confirmCancel(event),
                        onViewRegistrations: () {
                          ref
                              .read(registrationEventFilterProvider.notifier)
                              .select(event.id);
                          context.go(AppRoutes.organizerRegistrations);
                        },
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

  Future<void> _duplicateEvent(OrganizerEventRecord event) async {
    final copy = await ref
        .read(organizerEventsControllerProvider.notifier)
        .duplicateEvent(event.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Duplicated "${copy.title}" as draft.')),
    );
  }

  Future<void> _confirmCancel(OrganizerEventRecord event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Event?'),
        content: Text(
          'Mark "${event.title}" as cancelled? Registered students will see this status.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep Event'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancel Event'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref
        .read(organizerEventsControllerProvider.notifier)
        .cancelEvent(event.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cancelled "${event.title}".')),
    );
  }
}

class _OrganizerEventRowCard extends StatelessWidget {
  const _OrganizerEventRowCard({
    required this.event,
    required this.onEdit,
    required this.onDuplicate,
    required this.onViewRegistrations,
    this.onCancel,
  });

  final OrganizerEventRecord event;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onViewRegistrations;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = DeviceScreenType.of(context) == DeviceScreenType.mobile;
    final statusColor = switch (event.status) {
      OrganizerEventStatus.draft => AppColors.warning,
      OrganizerEventStatus.published => AppColors.success,
      OrganizerEventStatus.completed => AppColors.secondary,
      OrganizerEventStatus.cancelled => AppColors.error,
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMobile) ...[
                CampusNetworkImage(
                  imageUrl: event.bannerUrl,
                  width: 112,
                  height: 82,
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
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.16),
                            borderRadius: AppRadii.borderPill,
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.45),
                            ),
                          ),
                          child: Text(
                            event.status.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: AppRadii.borderPill,
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Text(
                            event.registrationMode.label,
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(event.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${DateFormat('EEE, d MMM · h:mm a').format(event.startTime)} · ${event.venue}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${event.registeredCount}/${event.capacity} registered · ${event.registrationQuestions.length} custom questions',
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
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              AppButton(
                label: 'Edit',
                size: AppButtonSize.sm,
                variant: AppButtonVariant.primary,
                leadingIcon: Icons.edit_outlined,
                onPressed: onEdit,
              ),
              AppButton(
                label: 'Duplicate',
                size: AppButtonSize.sm,
                variant: AppButtonVariant.outline,
                leadingIcon: Icons.copy_outlined,
                onPressed: onDuplicate,
              ),
              AppButton(
                label: 'Registrations',
                size: AppButtonSize.sm,
                variant: AppButtonVariant.outline,
                leadingIcon: Icons.people_outline_rounded,
                onPressed: onViewRegistrations,
              ),
              if (onCancel != null)
                AppButton(
                  label: 'Cancel',
                  size: AppButtonSize.sm,
                  variant: AppButtonVariant.ghost,
                  leadingIcon: Icons.cancel_outlined,
                  onPressed: onCancel,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
