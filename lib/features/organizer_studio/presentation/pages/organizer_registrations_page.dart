import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/core/utils/csv_exporter.dart';
import 'package:bennett_campus/features/organizer_studio/domain/models/organizer_models.dart';
import 'package:bennett_campus/features/organizer_studio/presentation/providers/organizer_providers.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Organizer participant table, response inspector, filters, and CSV export.
class OrganizerRegistrationsPage extends ConsumerStatefulWidget {
  const OrganizerRegistrationsPage({super.key});

  @override
  ConsumerState<OrganizerRegistrationsPage> createState() =>
      _OrganizerRegistrationsPageState();
}

class _OrganizerRegistrationsPageState
    extends ConsumerState<OrganizerRegistrationsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  RegistrationStatus? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final events =
        ref.watch(organizerEventsControllerProvider).value ?? const [];
    final eventTitlesById = {for (final e in events) e.id: e.title};
    final selectedEventId = ref.watch(registrationEventFilterProvider);
    final effectiveEventId =
        selectedEventId != null && eventTitlesById.containsKey(selectedEventId)
        ? selectedEventId
        : null;

    final registrationsAsync = ref.watch(organizerClubRegistrationsProvider);
    final isMobile = DeviceScreenType.of(context) == DeviceScreenType.mobile;

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            registrationsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: AppLoadingIndicator(
                  message: 'Loading club registrations...',
                ),
              ),
              error: (error, _) => AppErrorWidget(
                message: error.toString(),
                onRetry: () =>
                    ref.invalidate(organizerClubRegistrationsProvider),
              ),
              data: (registrations) {
                final normalized = _query.trim().toLowerCase();
                final filtered = registrations.where((reg) {
                  if (effectiveEventId != null &&
                      reg.eventId != effectiveEventId) {
                    return false;
                  }
                  if (_statusFilter != null && reg.status != _statusFilter) {
                    return false;
                  }
                  if (normalized.isEmpty) return true;
                  return reg.studentName.toLowerCase().contains(normalized) ||
                      reg.studentEmail.toLowerCase().contains(normalized) ||
                      reg.ticketCode.toLowerCase().contains(normalized);
                }).toList();

                return Column(
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
                            Text(
                              'Registration Management',
                              style: theme.textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Inspect participant details, custom responses, and export CSV rosters.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        AppButton(
                          label: 'Export CSV',
                          leadingIcon: Icons.download_rounded,
                          variant: AppButtonVariant.secondary,
                          onPressed: filtered.isEmpty
                              ? null
                              : () => _openCsvExportDialog(
                                  context,
                                  filtered,
                                  eventTitlesById,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 220,
                              maxWidth: 320,
                            ),
                            child: AppSearchBar(
                              controller: _searchController,
                              hintText: 'Search name, email, or ticket...',
                              onChanged: (v) => setState(() => _query = v),
                              onClear: () => setState(() => _query = ''),
                            ),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 200,
                              maxWidth: 280,
                            ),
                            child: DropdownButtonFormField<String?>(
                              initialValue: effectiveEventId,
                              isExpanded: true,
                              dropdownColor: AppColors.surfaceElevated,
                              decoration: const InputDecoration(
                                labelText: 'Filter by Event',
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('All Club Events'),
                                ),
                                ...events.map(
                                  (e) => DropdownMenuItem<String?>(
                                    value: e.id,
                                    child: Text(
                                      e.title,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                ref
                                    .read(
                                      registrationEventFilterProvider.notifier,
                                    )
                                    .select(value);
                              },
                            ),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 160,
                              maxWidth: 210,
                            ),
                            child: DropdownButtonFormField<RegistrationStatus?>(
                              initialValue: _statusFilter,
                              isExpanded: true,
                              dropdownColor: AppColors.surfaceElevated,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem<RegistrationStatus?>(
                                  value: null,
                                  child: Text('All Statuses'),
                                ),
                                ...RegistrationStatus.values.map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status.label),
                                  ),
                                ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _statusFilter = value),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${filtered.length} participant${filtered.length == 1 ? '' : 's'} shown',
                      style: theme.textTheme.labelMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (filtered.isEmpty)
                      AppCard(
                        child: Text(
                          'No participant registrations match the active filters.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    else if (isMobile)
                      Column(
                        children: filtered.map((reg) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _MobileParticipantCard(
                              registration: reg,
                              eventTitle:
                                  eventTitlesById[reg.eventId] ?? reg.eventId,
                              onInspect: () => _openResponsesDialog(
                                context,
                                reg,
                                events,
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    else
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: LayoutBuilder(
                          builder: (context, constraints) =>
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: constraints.maxWidth,
                                  ),
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                      AppColors.surfaceElevated,
                                    ),
                                    columns: const [
                                      DataColumn(label: Text('Student')),
                                      DataColumn(label: Text('Event')),
                                      DataColumn(label: Text('Ticket')),
                                      DataColumn(label: Text('Status')),
                                      DataColumn(label: Text('Registered')),
                                      DataColumn(label: Text('Responses')),
                                    ],
                                    rows: filtered.map((reg) {
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  reg.studentName,
                                                  style: theme
                                                      .textTheme.titleSmall,
                                                ),
                                                Text(
                                                  reg.studentEmail,
                                                  style:
                                                      theme.textTheme.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                          DataCell(
                                            ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 220,
                                              ),
                                              child: Text(
                                                eventTitlesById[reg.eventId] ??
                                                    reg.eventId,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(reg.ticketCode)),
                                          DataCell(
                                            _StatusBadge(status: reg.status),
                                          ),
                                          DataCell(
                                            Text(
                                              DateFormat('d MMM, h:mm a')
                                                  .format(reg.registeredAt),
                                            ),
                                          ),
                                          DataCell(
                                            TextButton(
                                              onPressed: () =>
                                                  _openResponsesDialog(
                                                    context,
                                                    reg,
                                                    events,
                                                  ),
                                              child: Text(
                                                reg.answers.isEmpty
                                                    ? 'Profile'
                                                    : 'View (${reg.answers.length})',
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openResponsesDialog(
    BuildContext context,
    EventRegistration reg,
    List<OrganizerEventRecord> events,
  ) {
    final theme = Theme.of(context);
    final event = events.where((e) => e.id == reg.eventId).firstOrNull;
    final questionLabels = {
      for (final q
          in event?.registrationQuestions ?? const <RegistrationQuestion>[])
        q.id: q.label,
    };

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(reg.studentName),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${reg.studentEmail} · ${reg.studentProgram}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ticket: ${reg.ticketCode} · ${reg.status.label}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                if (reg.answers.isEmpty)
                  Text(
                    'Registered using Mode A (One-Click Basic). No custom form answers submitted.',
                    style: theme.textTheme.bodyMedium,
                  )
                else
                  ...reg.answers.entries.map((entry) {
                    final label = questionLabels[entry.key] ?? entry.key;
                    final value = entry.value is UploadedFileMetadata
                        ? '${(entry.value as UploadedFileMetadata).fileName} (${(entry.value as UploadedFileMetadata).formattedSize})'
                        : (entry.value is List
                              ? (entry.value as List).join(', ')
                              : entry.value.toString());
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: theme.textTheme.labelSmall),
                          const SizedBox(height: 2),
                          Text(
                            value,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _openCsvExportDialog(
    BuildContext context,
    List<EventRegistration> registrations,
    Map<String, String> eventTitlesById,
  ) {
    final csv = CsvExporter.buildParticipantsCsv(
      registrations: registrations,
      eventTitlesById: eventTitlesById,
    );

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Participant CSV Export'),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${registrations.length} row(s) formatted as RFC-4180 CSV.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 260),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadii.borderMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    csv,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: csv));
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied participant CSV.')),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy CSV'),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final RegistrationStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      RegistrationStatus.confirmed => AppColors.success,
      RegistrationStatus.completed => AppColors.secondary,
      RegistrationStatus.cancelled => AppColors.error,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: AppRadii.borderPill,
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _MobileParticipantCard extends StatelessWidget {
  const _MobileParticipantCard({
    required this.registration,
    required this.eventTitle,
    required this.onInspect,
  });

  final EventRegistration registration;
  final String eventTitle;
  final VoidCallback onInspect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  registration.studentName,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              _StatusBadge(status: registration.status),
            ],
          ),
          Text(registration.studentEmail, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$eventTitle · ${registration.ticketCode}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'View Details',
            size: AppButtonSize.sm,
            variant: AppButtonVariant.outline,
            onPressed: onInspect,
          ),
        ],
      ),
    );
  }
}
