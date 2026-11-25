import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/auth/domain/models/student_user.dart';
import 'package:bennett_campus/features/auth/presentation/providers/auth_provider.dart';
import 'package:bennett_campus/features/student_portal/data/mock/mock_campus_data.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';
import 'package:bennett_campus/features/student_portal/presentation/providers/student_portal_providers.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/dynamic_registration_form.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Registration flow supporting Mode A (Basic one-click) and Mode B (Custom form).
class EventRegistrationPage extends ConsumerStatefulWidget {
  const EventRegistrationPage({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<EventRegistrationPage> createState() =>
      _EventRegistrationPageState();
}

class _EventRegistrationPageState extends ConsumerState<EventRegistrationPage> {
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final event = MockCampusData.events
        .where((e) => e.id == widget.eventId)
        .firstOrNull;
    final user = ref.watch(authControllerProvider).user;

    if (event == null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppErrorWidget(
          title: 'Event not found',
          message: 'Could not locate registration details for "${widget.eventId}".',
          retryLabel: 'Back to Explore',
          onRetry: () => context.go(AppRoutes.explore),
        ),
      );
    }

    final existingRegistration = ref.watch(
      activeRegistrationForEventProvider(event.id),
    );
    final isDesktop = DeviceScreenType.of(context) == DeviceScreenType.desktop;

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.eventDetail(event.id)),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to Event Details'),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              event.registrationMode == RegistrationMode.basic
                  ? 'Quick Event Registration'
                  : 'Event Registration Form',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              event.registrationMode == RegistrationMode.basic
                  ? 'Verify your Bennett student details and register in one click.'
                  : 'Complete the organizer-configured registration questions below.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (existingRegistration != null)
              _BlockedRegistrationCard(
                icon: Icons.check_circle_outline_rounded,
                accentColor: AppColors.success,
                title: 'Already Registered',
                message:
                    'You already hold an active pass (${existingRegistration.ticketCode}) for ${event.title}. Duplicate registrations are prevented.',
                primaryLabel: 'View Registration Ticket',
                onPrimaryTap: () => context.go(
                  AppRoutes.ticketDetail(existingRegistration.id),
                ),
                secondaryLabel: 'Back to Event',
                onSecondaryTap: () =>
                    context.go(AppRoutes.eventDetail(event.id)),
              )
            else if (event.isCompleted || event.isRegistrationClosed)
              _BlockedRegistrationCard(
                icon: Icons.event_busy_outlined,
                accentColor: AppColors.warning,
                title: event.isCompleted
                    ? 'Event Completed'
                    : 'Registrations Closed',
                message: event.isCompleted
                    ? 'This campus event has already taken place.'
                    : 'The registration window closed on ${DateFormat('d MMM, h:mm a').format(event.registrationDeadline)}.',
                primaryLabel: 'Explore Upcoming Events',
                onPrimaryTap: () => context.go(AppRoutes.explore),
                secondaryLabel: 'Back to Event',
                onSecondaryTap: () =>
                    context.go(AppRoutes.eventDetail(event.id)),
              )
            else if (event.isFull)
              _BlockedRegistrationCard(
                icon: Icons.group_off_outlined,
                accentColor: AppColors.error,
                title: 'Event at Full Capacity',
                message:
                    'All ${event.capacity} spots for ${event.title} are currently filled.',
                primaryLabel: 'Explore Other Events',
                onPrimaryTap: () => context.go(AppRoutes.explore),
                secondaryLabel: 'Back to Event',
                onSecondaryTap: () =>
                    context.go(AppRoutes.eventDetail(event.id)),
              )
            else if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: _buildFormColumn(context, event, user),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(
                    flex: 4,
                    child: _EventRegistrationSummary(event: event),
                  ),
                ],
              )
            else ...[
              _EventRegistrationSummary(event: event),
              const SizedBox(height: AppSpacing.lg),
              _buildFormColumn(context, event, user),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormColumn(
    BuildContext context,
    CampusEvent event,
    StudentUser? user,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_errorMessage != null) ...[
          AppErrorWidget(
            title: 'Unable to complete registration',
            message: _errorMessage!,
            compact: true,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (user != null) ...[
          _StudentProfileSummaryCard(student: user),
          const SizedBox(height: AppSpacing.lg),
        ],
        AppCard(
          child: event.registrationMode == RegistrationMode.basic
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'One-Click Confirmation',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Your verified Bennett University student identity above will be attached to your registration pass.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Confirm Registration',
                      leadingIcon: Icons.confirmation_number_outlined,
                      isLoading: _isSubmitting,
                      fullWidth: true,
                      size: AppButtonSize.lg,
                      onPressed: () => _submitRegistration(event, const {}),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registration Questions',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Fields marked with * are required by ${event.clubName}.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DynamicRegistrationForm(
                      questions: event.registrationQuestions,
                      isSubmitting: _isSubmitting,
                      onSubmit: (answers) => _submitRegistration(event, answers),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _submitRegistration(
    CampusEvent event,
    Map<String, dynamic> answers,
  ) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final created = await ref
          .read(registrationsControllerProvider.notifier)
          .registerForEvent(event: event, answers: answers);
      if (!mounted) return;
      context.go('${AppRoutes.ticketDetail(created.id)}?confirmed=true');
    } on RegistrationException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unexpected error while submitting registration.';
        _isSubmitting = false;
      });
    }
  }
}

class _StudentProfileSummaryCard extends StatelessWidget {
  const _StudentProfileSummaryCard({required this.student});

  final StudentUser student;

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
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Text(
                  student.initials,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.fullName, style: theme.textTheme.titleMedium),
                    Text(
                      student.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondaryMuted,
                  borderRadius: AppRadii.borderPill,
                ),
                child: Text(
                  'Auto-filled',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${student.program} · ${student.batchYear}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _EventRegistrationSummary extends StatelessWidget {
  const _EventRegistrationSummary({required this.event});

  final CampusEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('EEE, d MMM · h:mm a').format(event.startTime);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CampusNetworkImage(
            imageUrl: event.bannerUrl,
            height: 148,
            width: double.infinity,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadii.lg - 1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EVENT SUMMARY',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(event.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(event.clubName, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                _SummaryItem(icon: Icons.calendar_today_outlined, text: dateLabel),
                _SummaryItem(icon: Icons.location_on_outlined, text: event.venue),
                _SummaryItem(icon: Icons.group_outlined, text: event.teamSizeLabel),
                _SummaryItem(
                  icon: Icons.event_seat_outlined,
                  text: '${event.spotsRemaining} of ${event.capacity} spots left',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockedRegistrationCard extends StatelessWidget {
  const _BlockedRegistrationCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimaryTap,
    required this.secondaryLabel,
    required this.onSecondaryTap,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimaryTap;
  final String secondaryLabel;
  final VoidCallback onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      borderColor: accentColor.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.16),
              borderRadius: AppRadii.borderMd,
            ),
            child: Icon(icon, color: accentColor),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(message, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppButton(label: primaryLabel, onPressed: onPrimaryTap),
              AppButton(
                label: secondaryLabel,
                variant: AppButtonVariant.outline,
                onPressed: onSecondaryTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
