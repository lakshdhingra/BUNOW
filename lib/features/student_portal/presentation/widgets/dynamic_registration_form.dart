import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Dynamically renders organizer-configured registration questions (Mode B).
class DynamicRegistrationForm extends StatefulWidget {
  const DynamicRegistrationForm({
    super.key,
    required this.questions,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final List<RegistrationQuestion> questions;
  final bool isSubmitting;
  final ValueChanged<Map<String, dynamic>> onSubmit;

  @override
  State<DynamicRegistrationForm> createState() =>
      _DynamicRegistrationFormState();
}

class _DynamicRegistrationFormState extends State<DynamicRegistrationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, dynamic> _answers = {};
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    for (final q in widget.questions) {
      if (q.type == QuestionFieldType.shortText ||
          q.type == QuestionFieldType.longText ||
          q.type == QuestionFieldType.number) {
        _textControllers[q.id] = TextEditingController();
      } else if (q.type == QuestionFieldType.multipleChoice) {
        _answers[q.id] = <String>[];
      } else if (q.type == QuestionFieldType.checkbox) {
        _answers[q.id] = false;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _validateCustomFields() {
    for (final q in widget.questions) {
      if (!q.isRequired) continue;
      final value = _answers[q.id];
      final missing = switch (q.type) {
        QuestionFieldType.singleChoice =>
          value == null || value.toString().isEmpty,
        QuestionFieldType.multipleChoice =>
          value is! List<String> || value.isEmpty,
        QuestionFieldType.checkbox => value != true,
        QuestionFieldType.fileUpload => value is! UploadedFileMetadata,
        _ => false,
      };
      if (missing) return false;
    }
    return true;
  }

  void _handleSubmit() {
    setState(() => _showValidationErrors = true);

    final formValid = _formKey.currentState?.validate() ?? false;
    final customValid = _validateCustomFields();
    if (!formValid || !customValid) return;

    final payload = <String, dynamic>{..._answers};
    for (final entry in _textControllers.entries) {
      final text = entry.value.text.trim();
      if (text.isNotEmpty) {
        payload[entry.key] = text;
      }
    }
    widget.onSubmit(payload);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.questions.map(
            (question) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: _buildQuestionField(context, question),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppButton(
            label: 'Complete Registration',
            leadingIcon: Icons.check_circle_outline_rounded,
            isLoading: widget.isSubmitting,
            fullWidth: true,
            size: AppButtonSize.lg,
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionField(
    BuildContext context,
    RegistrationQuestion question,
  ) {
    return switch (question.type) {
      QuestionFieldType.shortText => AppTextField(
        controller: _textControllers[question.id],
        label: _requiredLabel(question),
        hintText: question.hintText,
        helperText: question.helperText,
        validator: (value) {
          if (question.isRequired && (value == null || value.trim().isEmpty)) {
            return 'This field is required.';
          }
          return null;
        },
      ),
      QuestionFieldType.longText => AppTextField(
        controller: _textControllers[question.id],
        label: _requiredLabel(question),
        hintText: question.hintText,
        helperText: question.helperText,
        minLines: 3,
        maxLines: 5,
        validator: (value) {
          if (question.isRequired && (value == null || value.trim().isEmpty)) {
            return 'Please provide a response.';
          }
          return null;
        },
      ),
      QuestionFieldType.number => TextFormField(
        controller: _textControllers[question.id],
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
        decoration: InputDecoration(
          labelText: _requiredLabel(question),
          hintText: question.hintText,
          helperText: question.helperText,
        ),
        validator: (value) {
          final trimmed = value?.trim() ?? '';
          if (question.isRequired && trimmed.isEmpty) {
            return 'Please enter a valid number.';
          }
          if (trimmed.isNotEmpty && int.tryParse(trimmed) == null) {
            return 'Digits only.';
          }
          return null;
        },
      ),
      QuestionFieldType.dropdown => DropdownButtonFormField<String>(
        initialValue: _answers[question.id] as String?,
        isExpanded: true,
        dropdownColor: AppColors.surfaceElevated,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: _requiredLabel(question),
          helperText: question.helperText,
        ),
        items: question.options
            .map(
              (option) => DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _answers[question.id] = value),
        validator: (value) {
          if (question.isRequired && (value == null || value.isEmpty)) {
            return 'Please select an option.';
          }
          return null;
        },
      ),
      QuestionFieldType.singleChoice => _SingleChoiceField(
        question: question,
        selectedValue: _answers[question.id] as String?,
        showError: _showValidationErrors,
        onSelected: (value) => setState(() => _answers[question.id] = value),
      ),
      QuestionFieldType.multipleChoice => _MultipleChoiceField(
        question: question,
        selectedValues: (_answers[question.id] as List<String>?) ?? const [],
        showError: _showValidationErrors,
        onToggle: (option) {
          setState(() {
            final current = List<String>.from(
              (_answers[question.id] as List<String>?) ?? const [],
            );
            if (current.contains(option)) {
              current.remove(option);
            } else {
              current.add(option);
            }
            _answers[question.id] = current;
          });
        },
      ),
      QuestionFieldType.checkbox => _CheckboxField(
        question: question,
        value: _answers[question.id] == true,
        showError: _showValidationErrors,
        onChanged: (checked) => setState(() => _answers[question.id] = checked),
      ),
      QuestionFieldType.fileUpload => _FileUploadField(
        question: question,
        uploadedFile: _answers[question.id] as UploadedFileMetadata?,
        showError: _showValidationErrors,
        onPickFile: () => _pickFile(question.id),
        onClearFile: () => setState(() => _answers.remove(question.id)),
      ),
    };
  }

  Future<void> _pickFile(String questionId) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'ppt', 'pptx'],
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      setState(() {
        _answers[questionId] = UploadedFileMetadata(
          fileName: file.name,
          sizeBytes: file.size,
        );
      });
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File picker unavailable in this environment.'),
        ),
      );
    }
  }

  static String _requiredLabel(RegistrationQuestion question) {
    return question.isRequired ? '${question.label} *' : question.label;
  }
}

class _SingleChoiceField extends StatelessWidget {
  const _SingleChoiceField({
    required this.question,
    required this.selectedValue,
    required this.showError,
    required this.onSelected,
  });

  final RegistrationQuestion question;
  final String? selectedValue;
  final bool showError;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError =
        showError &&
        question.isRequired &&
        (selectedValue == null || selectedValue!.isEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.isRequired ? '${question.label} *' : question.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ...question.options.map((option) {
          final isSelected = selectedValue == option;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: InkWell(
              onTap: () => onSelected(option),
              borderRadius: AppRadii.borderMd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryMuted
                      : AppColors.background,
                  borderRadius: AppRadii.borderMd,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        option,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Please select one option.',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

class _MultipleChoiceField extends StatelessWidget {
  const _MultipleChoiceField({
    required this.question,
    required this.selectedValues,
    required this.showError,
    required this.onToggle,
  });

  final RegistrationQuestion question;
  final List<String> selectedValues;
  final bool showError;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError =
        showError && question.isRequired && selectedValues.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.isRequired ? '${question.label} *' : question.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: question.options.map((option) {
            final isSelected = selectedValues.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onToggle(option),
              selectedColor: AppColors.primaryMuted,
              checkmarkColor: AppColors.secondary,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            );
          }).toList(),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Select at least one option.',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

class _CheckboxField extends StatelessWidget {
  const _CheckboxField({
    required this.question,
    required this.value,
    required this.showError,
    required this.onChanged,
  });

  final RegistrationQuestion question;
  final bool value;
  final bool showError;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = showError && question.isRequired && !value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => onChanged(!value),
          borderRadius: AppRadii.borderMd,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadii.borderMd,
              border: Border.all(
                color: hasError
                    ? AppColors.error
                    : (value ? AppColors.primary : AppColors.border),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: value,
                  onChanged: (checked) => onChanged(checked ?? false),
                  activeColor: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      question.isRequired
                          ? '${question.label} *'
                          : question.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'You must confirm this checkbox to continue.',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

class _FileUploadField extends StatelessWidget {
  const _FileUploadField({
    required this.question,
    required this.uploadedFile,
    required this.showError,
    required this.onPickFile,
    required this.onClearFile,
  });

  final RegistrationQuestion question;
  final UploadedFileMetadata? uploadedFile;
  final bool showError;
  final VoidCallback onPickFile;
  final VoidCallback onClearFile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError =
        showError && question.isRequired && uploadedFile == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.isRequired ? '${question.label} *' : question.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        if (question.helperText != null) ...[
          const SizedBox(height: 2),
          Text(question.helperText!, style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppRadii.borderMd,
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : (uploadedFile != null ? AppColors.primary : AppColors.border),
            ),
          ),
          child: uploadedFile == null
              ? Row(
                  children: [
                    const Icon(
                      Icons.upload_file_outlined,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'PDF, PNG, JPG, or PPTX',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    AppButton(
                      label: 'Choose File',
                      variant: AppButtonVariant.outline,
                      size: AppButtonSize.sm,
                      onPressed: onPickFile,
                    ),
                  ],
                )
              : Row(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      color: AppColors.primaryHover,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            uploadedFile!.fileName,
                            style: theme.textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            uploadedFile!.formattedSize,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove file',
                      onPressed: onClearFile,
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Please attach the required file.',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}
