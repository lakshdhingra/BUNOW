import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/organizer_studio/domain/models/attendance_models.dart';
import 'package:bennett_campus/features/organizer_studio/presentation/providers/organizer_providers.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Organizer Attendance & Check-In workspace with QR scanner UI and manual lookup.
class OrganizerAttendancePage extends ConsumerStatefulWidget {
  const OrganizerAttendancePage({super.key});

  @override
  ConsumerState<OrganizerAttendancePage> createState() =>
      _OrganizerAttendancePageState();
}

class _OrganizerAttendancePageState
    extends ConsumerState<OrganizerAttendancePage> {
  final TextEditingController _ticketCodeController = TextEditingController();
  final TextEditingController _lookupController = TextEditingController();
  String _lookupQuery = '';
  String? _feedbackMessage;
  bool _feedbackIsError = false;
  bool _feedbackIsDuplicate = false;

  @override
  void dispose() {
    _ticketCodeController.dispose();
    _lookupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final events =
        ref.watch(organizerEventsControllerProvider).value ?? const [];
    final selectedEventId = ref.watch(selectedAttendanceEventIdProvider);
    final effectiveEventId =
        selectedEventId != null && events.any((e) => e.id == selectedEventId)
        ? selectedEventId
        : (events.isNotEmpty ? events.first.id : null);

    final attendanceAsync = ref.watch(eventAttendanceControllerProvider);
    final isDesktop = DeviceScreenType.of(context) == DeviceScreenType.desktop;

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
                    Text(
                      'Attendance & Check-In',
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Scan student QR passes or verify attendance manually with duplicate check-in protection.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                if (events.isNotEmpty && effectiveEventId != null)
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 220,
                      maxWidth: 320,
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: effectiveEventId,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceElevated,
                      decoration: const InputDecoration(
                        labelText: 'Active Check-In Event',
                        isDense: true,
                      ),
                      items: events
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e.id,
                              child: Text(
                                e.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _feedbackMessage = null);
                          ref
                              .read(selectedAttendanceEventIdProvider.notifier)
                              .select(value);
                        }
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_feedbackMessage != null) ...[
              _CheckInFeedbackBanner(
                message: _feedbackMessage!,
                isError: _feedbackIsError,
                isDuplicate: _feedbackIsDuplicate,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            attendanceAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: AppLoadingIndicator(
                  message: 'Loading attendance roster...',
                ),
              ),
              error: (error, _) => AppErrorWidget(
                message: error.toString(),
                onRetry: () =>
                    ref.invalidate(eventAttendanceControllerProvider),
              ),
              data: (records) {
                final checkedInCount = records
                    .where((r) => r.status == AttendanceStatus.checkedIn)
                    .length;
                final pendingCount = records
                    .where((r) => r.status == AttendanceStatus.pending)
                    .length;

                final scannerCard = _QrScannerCard(
                  controller: _ticketCodeController,
                  sampleRecords: records,
                  onScanCode: (code) => _handleTicketScan(code),
                );

                final lookupCard = _ManualLookupCard(
                  controller: _lookupController,
                  query: _lookupQuery,
                  records: records,
                  checkedInCount: checkedInCount,
                  pendingCount: pendingCount,
                  onQueryChanged: (val) => setState(() => _lookupQuery = val),
                  onClearQuery: () => setState(() => _lookupQuery = ''),
                  onCheckIn: (record) => _handleManualCheckIn(record),
                );

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: scannerCard),
                      const SizedBox(width: AppSpacing.xl),
                      Expanded(flex: 7, child: lookupCard),
                    ],
                  );
                }

                return Column(
                  children: [
                    scannerCard,
                    const SizedBox(height: AppSpacing.lg),
                    lookupCard,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTicketScan(String rawCode) async {
    final code = rawCode.trim();
    if (code.isEmpty) return;

    try {
      final updated = await ref
          .read(eventAttendanceControllerProvider.notifier)
          .checkInByTicketCode(code);
      if (!mounted) return;
      _ticketCodeController.clear();
      setState(() {
        _feedbackMessage =
            'Checked in ${updated.studentName} (${updated.ticketCode}).';
        _feedbackIsError = false;
        _feedbackIsDuplicate = false;
      });
    } on CheckInException catch (e) {
      if (!mounted) return;
      setState(() {
        _feedbackMessage = e.message;
        _feedbackIsError = true;
        _feedbackIsDuplicate = e.isDuplicate;
      });
    }
  }

  Future<void> _handleManualCheckIn(AttendanceCheckInRecord record) async {
    try {
      final updated = await ref
          .read(eventAttendanceControllerProvider.notifier)
          .checkInManually(record.registrationId);
      if (!mounted) return;
      setState(() {
        _feedbackMessage =
            'Manually checked in ${updated.studentName} (${updated.ticketCode}).';
        _feedbackIsError = false;
        _feedbackIsDuplicate = false;
      });
    } on CheckInException catch (e) {
      if (!mounted) return;
      setState(() {
        _feedbackMessage = e.message;
        _feedbackIsError = true;
        _feedbackIsDuplicate = e.isDuplicate;
      });
    }
  }
}

class _QrScannerCard extends StatelessWidget {
  const _QrScannerCard({
    required this.controller,
    required this.sampleRecords,
    required this.onScanCode,
  });

  final TextEditingController controller;
  final List<AttendanceCheckInRecord> sampleRecords;
  final ValueChanged<String> onScanCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_scanner_rounded, color: AppColors.secondary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'QR Ticket Scanner',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Point camera at a student pass or enter a ticket code to verify check-in.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 176,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadii.borderLg,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.borderMd,
                    border: Border.all(
                      color: AppColors.secondary,
                      width: 2,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.qr_code_2_rounded,
                      size: 48,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Scanner Ready (Mock Mode)',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: controller,
            label: 'Ticket Code Input',
            hintText: 'e.g. BU-CSI-4821',
            onFieldSubmitted: onScanCode,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Scan & Check In',
            leadingIcon: Icons.verified_outlined,
            fullWidth: true,
            onPressed: () => onScanCode(controller.text),
          ),
          if (sampleRecords.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Quick Simulate Scan:', style: theme.textTheme.labelSmall),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: sampleRecords.take(3).map((rec) {
                return ActionChip(
                  label: Text(rec.ticketCode),
                  onPressed: () => onScanCode(rec.ticketCode),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ManualLookupCard extends StatelessWidget {
  const _ManualLookupCard({
    required this.controller,
    required this.query,
    required this.records,
    required this.checkedInCount,
    required this.pendingCount,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onCheckIn,
  });

  final TextEditingController controller;
  final String query;
  final List<AttendanceCheckInRecord> records;
  final int checkedInCount;
  final int pendingCount;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final ValueChanged<AttendanceCheckInRecord> onCheckIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = query.trim().toLowerCase();
    final filtered = records.where((r) {
      if (normalized.isEmpty) return true;
      return r.studentName.toLowerCase().contains(normalized) ||
          r.studentEmail.toLowerCase().contains(normalized) ||
          r.ticketCode.toLowerCase().contains(normalized);
    }).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Manual Student Lookup', style: theme.textTheme.headlineSmall),
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  _CountPill(
                    label: '$checkedInCount Checked In',
                    color: AppColors.success,
                  ),
                  _CountPill(
                    label: '$pendingCount Pending',
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppSearchBar(
            controller: controller,
            hintText: 'Lookup by student name, email, or ticket...',
            onChanged: onQueryChanged,
            onClear: onClearQuery,
          ),
          const SizedBox(height: AppSpacing.md),
          if (filtered.isEmpty)
            Text(
              'No participants match your search query.',
              style: theme.textTheme.bodyMedium,
            )
          else
            ...filtered.map((rec) {
              final statusColor = switch (rec.status) {
                AttendanceStatus.checkedIn => AppColors.success,
                AttendanceStatus.pending => AppColors.secondary,
                AttendanceStatus.cancelled => AppColors.error,
              };

              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadii.borderMd,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rec.studentName, style: theme.textTheme.titleSmall),
                          Text(
                            '${rec.studentEmail} · ${rec.ticketCode}',
                            style: theme.textTheme.bodySmall,
                          ),
                          if (rec.checkedInAt != null)
                            Text(
                              'Checked in at ${DateFormat('h:mm a').format(rec.checkedInAt!)}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _CountPill(
                          label: rec.status.label,
                          color: statusColor,
                        ),
                        AppButton(
                          label: rec.status == AttendanceStatus.checkedIn
                              ? 'Checked In'
                              : 'Check In',
                          size: AppButtonSize.sm,
                          variant: rec.status == AttendanceStatus.checkedIn
                              ? AppButtonVariant.outline
                              : AppButtonVariant.primary,
                          onPressed: rec.status == AttendanceStatus.cancelled
                              ? null
                              : () => onCheckIn(rec),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _CheckInFeedbackBanner extends StatelessWidget {
  const _CheckInFeedbackBanner({
    required this.message,
    required this.isError,
    required this.isDuplicate,
  });

  final String message;
  final bool isError;
  final bool isDuplicate;

  @override
  Widget build(BuildContext context) {
    final color = isDuplicate
        ? AppColors.warning
        : (isError ? AppColors.error : AppColors.success);
    final icon = isDuplicate
        ? Icons.warning_amber_rounded
        : (isError ? Icons.error_outline_rounded : Icons.check_circle_rounded);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadii.borderMd,
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: AppRadii.borderPill,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
