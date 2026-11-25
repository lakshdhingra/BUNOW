import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/organizer_studio/domain/models/organizer_models.dart';
import 'package:bennett_campus/features/organizer_studio/presentation/providers/organizer_providers.dart';
import 'package:bennett_campus/features/organizer_studio/presentation/widgets/dynamic_form_builder.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// 6-step Event Creation & Editing Wizard for Bennett club organizers.
class EventWizardPage extends ConsumerStatefulWidget {
  const EventWizardPage({super.key, this.eventId});

  final String? eventId;

  @override
  ConsumerState<EventWizardPage> createState() => _EventWizardPageState();
}

class _EventWizardPageState extends ConsumerState<EventWizardPage> {
  static const List<String> _stepTitles = [
    'Basic Info',
    'Event Media',
    'Date & Venue',
    'Reg Mode',
    'Form Config',
    'Preview & Publish',
  ];

  static const List<({String label, String url})> _presetBanners = [
    (
      label: 'Hackathon Hub',
      url: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=1200&q=80',
    ),
    (
      label: 'Tech Seminar',
      url: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=1200&q=80',
    ),
    (
      label: 'Stage Showcase',
      url: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=1200&q=80',
    ),
  ];

  final GlobalKey<FormState> _stepFormKey = GlobalKey<FormState>();

  int _currentStep = 0;
  bool _initializedFromExisting = false;
  bool _isSaving = false;

  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _teamSizeController;
  late final TextEditingController _feeController;
  late final TextEditingController _bannerUrlController;
  late final TextEditingController _venueController;
  late final TextEditingController _capacityController;

  EventCategory _category = EventCategory.workshops;
  DateTime _startTime = DateTime(2026, 12, 15, 16, 0);
  DateTime _endTime = DateTime(2026, 12, 15, 19, 0);
  DateTime _deadline = DateTime(2026, 12, 14, 23, 59);
  RegistrationMode _registrationMode = RegistrationMode.basic;
  List<RegistrationQuestion> _questions = [];
  List<String> _mediaUrls = [];
  int _existingRegisteredCount = 0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _subtitleController = TextEditingController();
    _descriptionController = TextEditingController();
    _teamSizeController = TextEditingController(text: 'Individual');
    _feeController = TextEditingController(text: 'Free · Bennett Students');
    _bannerUrlController = TextEditingController(text: _presetBanners.first.url);
    _venueController = TextEditingController(text: 'P-Block Seminar Hall 204');
    _capacityController = TextEditingController(text: '120');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _teamSizeController.dispose();
    _feeController.dispose();
    _bannerUrlController.dispose();
    _venueController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _hydrateIfEditing(List<OrganizerEventRecord> events) {
    if (_initializedFromExisting || widget.eventId == null) return;
    final match = events.where((e) => e.id == widget.eventId).firstOrNull;
    if (match == null) return;

    _initializedFromExisting = true;
    _titleController.text = match.title;
    _subtitleController.text = match.subtitle;
    _descriptionController.text = match.description;
    _teamSizeController.text = match.teamSizeLabel;
    _feeController.text = match.feeLabel;
    _bannerUrlController.text = match.bannerUrl;
    _venueController.text = match.venue;
    _capacityController.text = match.capacity.toString();
    _category = match.category;
    _startTime = match.startTime;
    _endTime = match.endTime;
    _deadline = match.registrationDeadline;
    _registrationMode = match.registrationMode;
    _questions = List<RegistrationQuestion>.from(match.registrationQuestions);
    _mediaUrls = List<String>.from(match.mediaUrls);
    _existingRegisteredCount = match.registeredCount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeClub = ref.watch(activeOrganizerClubProvider);
    final eventsAsync = ref.watch(organizerEventsControllerProvider);
    if (eventsAsync.hasValue) {
      _hydrateIfEditing(eventsAsync.value!);
    }

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.organizerEvents),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to Event Management'),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.eventId == null ? 'Create New Event' : 'Edit Event',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 2),
            Text(
              'Publishing for ${activeClub?.name ?? 'assigned club'} · Step ${_currentStep + 1} of ${_stepTitles.length}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            _WizardStepBar(
              titles: _stepTitles,
              currentStep: _currentStep,
              onStepTap: (index) {
                if (index <= _currentStep) {
                  setState(() => _currentStep = index);
                }
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              child: Form(
                key: _stepFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepContent(context, activeClub),
                    const SizedBox(height: AppSpacing.xl),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        AppButton(
                          label: 'Previous',
                          variant: AppButtonVariant.outline,
                          onPressed: _currentStep == 0
                              ? null
                              : () => setState(() => _currentStep -= 1),
                        ),
                        if (_currentStep < _stepTitles.length - 1)
                          AppButton(
                            label: 'Continue',
                            trailingIcon: Icons.arrow_forward_rounded,
                            onPressed: _nextStep,
                          )
                        else
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              AppButton(
                                label: 'Save Draft',
                                variant: AppButtonVariant.outline,
                                isLoading: _isSaving,
                                onPressed: () => _saveEvent(
                                  OrganizerEventStatus.draft,
                                  activeClub,
                                ),
                              ),
                              AppButton(
                                label: 'Publish Event',
                                leadingIcon: Icons.rocket_launch_outlined,
                                isLoading: _isSaving,
                                onPressed: () => _saveEvent(
                                  OrganizerEventStatus.published,
                                  activeClub,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, CampusClub? activeClub) {
    final theme = Theme.of(context);

    return switch (_currentStep) {
      0 => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('1. Basic Information', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _titleController,
            label: 'Event Title *',
            hintText: 'e.g. Cloud Native Architecture Workshop',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Title is required.' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _subtitleController,
            label: 'Short Card Tagline *',
            hintText: 'One-sentence summary displayed on event cards',
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Tagline is required.'
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<EventCategory>(
            initialValue: _category,
            isExpanded: true,
            dropdownColor: AppColors.surfaceElevated,
            decoration: const InputDecoration(labelText: 'Category'),
            items: EventCategory.values
                .where((c) => c != EventCategory.all)
                .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _category = val);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _descriptionController,
            label: 'Full Event Description *',
            hintText: 'Explain what attendees will learn, build, or experience...',
            minLines: 4,
            maxLines: 6,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Description is required.'
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          ResponsiveCardGrid(
            desktopColumns: 2,
            tabletColumns: 2,
            mobileColumns: 1,
            children: [
              AppTextField(
                controller: _teamSizeController,
                label: 'Participation Format',
                hintText: 'e.g. Individual or Teams of 2–4',
              ),
              AppTextField(
                controller: _feeController,
                label: 'Entry / Eligibility',
                hintText: 'e.g. Free · Bennett Students',
              ),
            ],
          ),
        ],
      ),
      1 => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('2. Event Media & Poster', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Provide a banner poster URL or pick a campus preset.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _bannerUrlController,
            label: 'Cover Banner URL *',
            onChanged: (_) => setState(() {}),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Banner URL is required.'
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _presetBanners.map((preset) {
              return ActionChip(
                label: Text(preset.label),
                onPressed: () {
                  setState(() => _bannerUrlController.text = preset.url);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Banner Preview', style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          CampusNetworkImage(
            imageUrl: _bannerUrlController.text.trim(),
            height: 200,
            width: double.infinity,
            borderRadius: AppRadii.borderLg,
          ),
        ],
      ),
      2 => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('3. Date, Time & Venue', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          ResponsiveCardGrid(
            desktopColumns: 3,
            tabletColumns: 2,
            mobileColumns: 1,
            children: [
              _DatePickerTile(
                label: 'Start Date & Time',
                value: _startTime,
                onTap: () => _pickDateTime(_startTime, (d) {
                  setState(() => _startTime = d);
                }),
              ),
              _DatePickerTile(
                label: 'End Date & Time',
                value: _endTime,
                onTap: () => _pickDateTime(_endTime, (d) {
                  setState(() => _endTime = d);
                }),
              ),
              _DatePickerTile(
                label: 'Registration Deadline',
                value: _deadline,
                onTap: () => _pickDateTime(_deadline, (d) {
                  setState(() => _deadline = d);
                }),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ResponsiveCardGrid(
            desktopColumns: 2,
            tabletColumns: 2,
            mobileColumns: 1,
            children: [
              AppTextField(
                controller: _venueController,
                label: 'Campus Venue *',
                hintText: 'e.g. N-Block Innovation Hub',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Venue is required.'
                    : null,
              ),
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Participant Capacity *',
                  hintText: 'e.g. 150',
                ),
                validator: (v) {
                  final parsed = int.tryParse(v?.trim() ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter capacity > 0.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ],
      ),
      3 => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('4. Registration Mode', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choose how students will register for this event.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          ResponsiveCardGrid(
            desktopColumns: 2,
            tabletColumns: 2,
            mobileColumns: 1,
            children: [
              _ModeSelectorCard(
                title: 'Mode A · Basic One-Click',
                description:
                    'Auto-fills the student’s Bennett Microsoft profile (name, email, program) for instant 1-click registration.',
                icon: Icons.bolt_rounded,
                isSelected: _registrationMode == RegistrationMode.basic,
                onTap: () =>
                    setState(() => _registrationMode = RegistrationMode.basic),
              ),
              _ModeSelectorCard(
                title: 'Mode B · Advanced Custom Form',
                description:
                    'Build a custom registration questionnaire with short/long text, choices, dropdowns, numbers, checkboxes, and file uploads.',
                icon: Icons.dynamic_form_outlined,
                isSelected: _registrationMode == RegistrationMode.advanced,
                onTap: () =>
                    setState(() => _registrationMode = RegistrationMode.advanced),
              ),
            ],
          ),
        ],
      ),
      4 => _registrationMode == RegistrationMode.basic
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '5. Registration Configuration',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  elevated: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Basic One-Click Mode Active',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'No custom questions required. Student name, @bennett.edu.in email, program, and batch year will be captured automatically upon registration.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : DynamicFormBuilder(
              questions: _questions,
              onChanged: (updated) => setState(() => _questions = updated),
            ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('6. Preview & Publish', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Review all event details before saving as draft or publishing to the Student Portal.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          CampusNetworkImage(
            imageUrl: _bannerUrlController.text.trim(),
            height: 180,
            width: double.infinity,
            borderRadius: AppRadii.borderLg,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _titleController.text.trim().isEmpty
                ? 'Untitled Event'
                : _titleController.text.trim(),
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${activeClub?.name ?? ''} · ${_category.label} · ${_registrationMode.label}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _descriptionController.text.trim(),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.xs,
            children: [
              Text(
                'Starts: ${DateFormat('EEE, d MMM · h:mm a').format(_startTime)}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                'Venue: ${_venueController.text.trim()}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                'Capacity: ${_capacityController.text.trim()}',
                style: theme.textTheme.bodySmall,
              ),
              if (_registrationMode == RegistrationMode.advanced)
                Text(
                  'Custom Questions: ${_questions.length}',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ],
      ),
    };
  }

  void _nextStep() {
    if (!(_stepFormKey.currentState?.validate() ?? true)) return;
    if (_currentStep == 4 &&
        _registrationMode == RegistrationMode.advanced &&
        _questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add at least one custom question or switch to Basic registration mode.',
          ),
        ),
      );
      return;
    }
    setState(() => _currentStep += 1);
  }

  Future<void> _pickDateTime(
    DateTime current,
    ValueChanged<DateTime> onSelected,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2026, 1),
      lastDate: DateTime(2028, 12),
    );
    if (pickedDate == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (!mounted) return;
    final time = pickedTime ?? TimeOfDay.fromDateTime(current);
    onSelected(
      DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _saveEvent(
    OrganizerEventStatus targetStatus,
    CampusClub? activeClub,
  ) async {
    if (activeClub == null) return;
    setState(() => _isSaving = true);

    final record = OrganizerEventRecord(
      id: widget.eventId ?? 'evt-${DateTime.now().microsecondsSinceEpoch}',
      clubId: activeClub.id,
      clubName: activeClub.name,
      title: _titleController.text.trim().isEmpty
          ? 'Untitled Campus Event'
          : _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      status: targetStatus,
      startTime: _startTime,
      endTime: _endTime,
      registrationDeadline: _deadline,
      venue: _venueController.text.trim(),
      bannerUrl: _bannerUrlController.text.trim(),
      capacity: int.tryParse(_capacityController.text.trim()) ?? 100,
      registeredCount: _existingRegisteredCount,
      teamSizeLabel: _teamSizeController.text.trim(),
      feeLabel: _feeController.text.trim(),
      registrationMode: _registrationMode,
      registrationQuestions: _registrationMode == RegistrationMode.advanced
          ? _questions
          : const [],
      mediaUrls: _mediaUrls,
      updatedAt: DateTime.now(),
    );

    await ref.read(organizerEventsControllerProvider.notifier).saveEvent(record);
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          targetStatus == OrganizerEventStatus.published
              ? 'Published "${record.title}".'
              : 'Saved "${record.title}" as draft.',
        ),
      ),
    );
    context.go(AppRoutes.organizerEvents);
  }
}

class _WizardStepBar extends StatelessWidget {
  const _WizardStepBar({
    required this.titles,
    required this.currentStep,
    required this.onStepTap,
  });

  final List<String> titles;
  final int currentStep;
  final ValueChanged<int> onStepTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(titles.length, (index) {
          final isCurrent = index == currentStep;
          final isCompleted = index < currentStep;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: InkWell(
              onTap: () => onStepTap(index),
              borderRadius: AppRadii.borderPill,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.primary
                      : (isCompleted
                            ? AppColors.primaryMuted
                            : AppColors.surface),
                  borderRadius: AppRadii.borderPill,
                  border: Border.all(
                    color: isCurrent || isCompleted
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${index + 1}. ${titles[index]}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isCurrent || isCompleted
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      elevated: true,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  DateFormat('d MMM yyyy · h:mm a').format(value),
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeSelectorCard extends StatelessWidget {
  const _ModeSelectorCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      elevated: isSelected,
      borderColor: isSelected ? AppColors.primary : AppColors.border,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryMuted
                      : AppColors.background,
                  borderRadius: AppRadii.borderMd,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.primary : AppColors.secondary,
                ),
              ),
              const Spacer(),
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(description, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
