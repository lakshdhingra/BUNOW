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
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Registration confirmation & digital ticket page.
class RegistrationTicketPage extends ConsumerWidget {
  const RegistrationTicketPage({
    super.key,
    required this.registrationId,
    this.justConfirmed = false,
  });

  final String registrationId;
  final bool justConfirmed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final registrationsAsync = ref.watch(registrationsControllerProvider);

    if (registrationsAsync.isLoading && !registrationsAsync.hasValue) {
      return const AppLoadingIndicator(message: 'Loading your pass...');
    }

    final registration = ref.watch(registrationByIdProvider(registrationId));
    if (registration == null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppErrorWidget(
          title: 'Ticket not found',
          message: 'Could not find registration pass "$registrationId".',
          retryLabel: 'Go to My Events',
          onRetry: () => context.go(AppRoutes.myEvents),
        ),
      );
    }

    final event = MockCampusData.events
        .where((e) => e.id == registration.eventId)
        .firstOrNull;
    final isDesktop = DeviceScreenType.of(context) == DeviceScreenType.desktop;

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.myEvents),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to My Events'),
            ),
            const SizedBox(height: AppSpacing.md),
            if (justConfirmed &&
                registration.status == RegistrationStatus.confirmed) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.successMuted,
                  borderRadius: AppRadii.borderLg,
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.45),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registration Confirmed!',
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            'Your mock Bennett campus pass has been generated and saved to My Events.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: _DigitalTicketCard(
                      registration: registration,
                      event: event,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(
                    flex: 5,
                    child: _TicketActionsAndDetails(
                      registration: registration,
                      event: event,
                    ),
                  ),
                ],
              )
            else ...[
              _DigitalTicketCard(registration: registration, event: event),
              const SizedBox(height: AppSpacing.lg),
              _TicketActionsAndDetails(
                registration: registration,
                event: event,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DigitalTicketCard extends StatelessWidget {
  const _DigitalTicketCard({required this.registration, required this.event});

  final EventRegistration registration;
  final CampusEvent? event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (registration.status) {
      RegistrationStatus.confirmed => AppColors.success,
      RegistrationStatus.completed => AppColors.secondary,
      RegistrationStatus.cancelled => AppColors.error,
    };

    return AppCard(
      padding: EdgeInsets.zero,
      borderColor: AppColors.primary.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadii.lg - 1),
              ),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BENNETT UNIVERSITY · CAMPUS PASS',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.secondary,
                          letterSpacing: 0.9,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        event?.title ?? 'Campus Event Pass',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.16),
                    borderRadius: AppRadii.borderPill,
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    registration.status.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadii.borderMd,
                      ),
                      child: CustomPaint(
                        painter: _MockPassMatrixPainter(registration.ticketCode),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TICKET CODE', style: theme.textTheme.labelSmall),
                          const SizedBox(height: 2),
                          Text(
                            registration.ticketCode,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: AppColors.secondary,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Present this code at venue check-in.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xl,
                  runSpacing: AppSpacing.md,
                  children: [
                    _TicketField(
                      label: 'ATTENDEE',
                      value: registration.studentName,
                    ),
                    _TicketField(
                      label: 'EMAIL',
                      value: registration.studentEmail,
                    ),
                    if (event != null) ...[
                      _TicketField(
                        label: 'DATE & TIME',
                        value: DateFormat(
                          'EEE, d MMM · h:mm a',
                        ).format(event!.startTime),
                      ),
                      _TicketField(label: 'VENUE', value: event!.venue),
                    ],
                    _TicketField(
                      label: 'REGISTERED ON',
                      value: DateFormat(
                        'd MMM yyyy, h:mm a',
                      ).format(registration.registeredAt),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketActionsAndDetails extends ConsumerWidget {
  const _TicketActionsAndDetails({
    required this.registration,
    required this.event,
  });

  final EventRegistration registration;
  final CampusEvent? event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final questionLabels = {
      for (final q in event?.registrationQuestions ?? const <RegistrationQuestion>[])
        q.id: q.label,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pass Actions', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              if (event != null) ...[
                AppButton(
                  label: 'View Event Details',
                  variant: AppButtonVariant.outline,
                  leadingIcon: Icons.event_outlined,
                  fullWidth: true,
                  onPressed: () =>
                      context.go(AppRoutes.eventDetail(event!.id)),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              AppButton(
                label: 'Go to My Events',
                variant: AppButtonVariant.secondary,
                leadingIcon: Icons.confirmation_number_outlined,
                fullWidth: true,
                onPressed: () => context.go(AppRoutes.myEvents),
              ),
              if (registration.status == RegistrationStatus.confirmed) ...[
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Cancel Registration',
                  variant: AppButtonVariant.ghost,
                  leadingIcon: Icons.cancel_outlined,
                  fullWidth: true,
                  onPressed: () => _confirmCancel(context, ref),
                ),
              ],
            ],
          ),
        ),
        if (registration.answers.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Submitted Responses', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                ...registration.answers.entries.map((entry) {
                  final label = questionLabels[entry.key] ?? entry.key;
                  final displayValue = _formatAnswer(entry.value);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: theme.textTheme.labelSmall),
                        const SizedBox(height: 2),
                        Text(
                          displayValue,
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
        ],
      ],
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Registration?'),
        content: Text(
          'Your spot for ${event?.title ?? 'this event'} will be released.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep Pass'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancel Registration'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref
        .read(registrationsControllerProvider.notifier)
        .cancelRegistration(registration.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registration cancelled.')),
    );
  }

  static String _formatAnswer(dynamic value) {
    if (value is UploadedFileMetadata) {
      return '${value.fileName} (${value.formattedSize})';
    }
    if (value is List) return value.join(', ');
    if (value is bool) return value ? 'Confirmed' : 'No';
    return value.toString();
  }
}

class _TicketField extends StatelessWidget {
  const _TicketField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
    );
  }
}

/// Deterministic decorative QR-style grid seeded by [seed].
class _MockPassMatrixPainter extends CustomPainter {
  _MockPassMatrixPainter(this.seed);

  final String seed;

  @override
  void paint(Canvas canvas, Size size) {
    const grid = 9;
    final cell = size.width / grid;
    final darkPaint = Paint()..color = AppColors.background;
    final accentPaint = Paint()..color = AppColors.primary;

    final hash = seed.codeUnits.fold<int>(17, (acc, c) => acc * 31 + c);

    for (var row = 0; row < grid; row++) {
      for (var col = 0; col < grid; col++) {
        final isCornerFinder =
            (row < 3 && col < 3) ||
            (row < 3 && col >= grid - 3) ||
            (row >= grid - 3 && col < 3);
        final bit = ((hash >> ((row * grid + col) % 24)) & 1) == 1;
        if (isCornerFinder || bit) {
          canvas.drawRect(
            Rect.fromLTWH(col * cell + 0.5, row * cell + 0.5, cell - 1, cell - 1),
            isCornerFinder ? accentPaint : darkPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MockPassMatrixPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
