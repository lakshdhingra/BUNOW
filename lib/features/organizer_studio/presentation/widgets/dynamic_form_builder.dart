import 'package:flutter/material.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/student_portal/domain/models/registration_models.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/dynamic_registration_form.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Interactive builder for creating, editing, reordering, and previewing custom form questions.
class DynamicFormBuilder extends StatelessWidget {
  const DynamicFormBuilder({
    super.key,
    required this.questions,
    required this.onChanged,
  });

  final List<RegistrationQuestion> questions;
  final ValueChanged<List<RegistrationQuestion>> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Custom Form Builder', style: theme.textTheme.headlineSmall),
                Text(
                  '${questions.length} question${questions.length == 1 ? '' : 's'} configured',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                AppButton(
                  label: 'Preview Form',
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.sm,
                  leadingIcon: Icons.visibility_outlined,
                  onPressed: questions.isEmpty
                      ? null
                      : () => _openPreviewDialog(context),
                ),
                AppButton(
                  label: 'Add Question',
                  size: AppButtonSize.sm,
                  leadingIcon: Icons.add_rounded,
                  onPressed: () => _openQuestionEditor(context),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (questions.isEmpty)
          AppCard(
            elevated: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No custom questions added yet',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Add short text, dropdown, choice, number, checkbox, or file upload fields for students.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Add First Question',
                  size: AppButtonSize.sm,
                  leadingIcon: Icons.add_rounded,
                  onPressed: () => _openQuestionEditor(context),
                ),
              ],
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: questions.length,
            onReorder: (oldIndex, newIndex) {
              final next = List<RegistrationQuestion>.from(questions);
              if (newIndex > oldIndex) newIndex -= 1;
              final item = next.removeAt(oldIndex);
              next.insert(newIndex, item);
              onChanged(next);
            },
            itemBuilder: (context, index) {
              final q = questions[index];
              return Padding(
                key: ValueKey(q.id),
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  elevated: true,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ReorderableDragStartListener(
                            index: index,
                            child: const Padding(
                              padding: EdgeInsets.only(right: AppSpacing.sm),
                              child: Icon(
                                Icons.drag_indicator_rounded,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  q.label,
                                  style: theme.textTheme.titleSmall,
                                ),
                                const SizedBox(height: 2),
                                Wrap(
                                  spacing: AppSpacing.xs,
                                  runSpacing: AppSpacing.xxs,
                                  children: [
                                    _MetaPill(
                                      label: _typeLabel(q.type),
                                      color: AppColors.secondary,
                                    ),
                                    if (q.isRequired)
                                      const _MetaPill(
                                        label: 'Required',
                                        color: AppColors.primaryHover,
                                      )
                                    else
                                      const _MetaPill(
                                        label: 'Optional',
                                        color: AppColors.textMuted,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Move up',
                            onPressed: index == 0
                                ? null
                                : () => _move(index, index - 1),
                            icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                          ),
                          IconButton(
                            tooltip: 'Move down',
                            onPressed: index == questions.length - 1
                                ? null
                                : () => _move(index, index + 1),
                            icon: const Icon(
                              Icons.arrow_downward_rounded,
                              size: 18,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit question',
                            onPressed: () => _openQuestionEditor(
                              context,
                              existing: q,
                              index: index,
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                          ),
                          IconButton(
                            tooltip: 'Delete question',
                            onPressed: () {
                              final next = List<RegistrationQuestion>.from(
                                questions,
                              )..removeAt(index);
                              onChanged(next);
                            },
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      if (q.options.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Options: ${q.options.join(' · ')}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _move(int from, int to) {
    final next = List<RegistrationQuestion>.from(questions);
    final item = next.removeAt(from);
    next.insert(to, item);
    onChanged(next);
  }

  Future<void> _openPreviewDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Student Registration Form Preview',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Live interactive preview of your Mode B registration form.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: SingleChildScrollView(
                    child: DynamicRegistrationForm(
                      questions: questions,
                      isSubmitting: false,
                      onSubmit: (_) {
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Form preview validated cleanly.'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openQuestionEditor(
    BuildContext context, {
    RegistrationQuestion? existing,
    int? index,
  }) async {
    final result = await showDialog<RegistrationQuestion>(
      context: context,
      builder: (_) => _QuestionEditorDialog(existing: existing),
    );
    if (result == null) return;
    final next = List<RegistrationQuestion>.from(questions);
    if (index != null) {
      next[index] = result;
    } else {
      next.add(result);
    }
    onChanged(next);
  }

  static String _typeLabel(QuestionFieldType type) {
    return switch (type) {
      QuestionFieldType.shortText => 'Short Text',
      QuestionFieldType.longText => 'Long Text',
      QuestionFieldType.singleChoice => 'Single Choice',
      QuestionFieldType.multipleChoice => 'Multiple Choice',
      QuestionFieldType.dropdown => 'Dropdown',
      QuestionFieldType.checkbox => 'Checkbox',
      QuestionFieldType.number => 'Number',
      QuestionFieldType.fileUpload => 'File Upload',
    };
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadii.borderPill,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _QuestionEditorDialog extends StatefulWidget {
  const _QuestionEditorDialog({this.existing});

  final RegistrationQuestion? existing;

  @override
  State<_QuestionEditorDialog> createState() => _QuestionEditorDialogState();
}

class _QuestionEditorDialogState extends State<_QuestionEditorDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _hintController;
  late final TextEditingController _optionsController;
  late QuestionFieldType _type;
  late bool _isRequired;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _labelController = TextEditingController(text: existing?.label ?? '');
    _hintController = TextEditingController(text: existing?.hintText ?? '');
    _optionsController = TextEditingController(
      text: existing?.options.join(', ') ?? '',
    );
    _type = existing?.type ?? QuestionFieldType.shortText;
    _isRequired = existing?.isRequired ?? true;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _hintController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  bool get _needsOptions =>
      _type == QuestionFieldType.singleChoice ||
      _type == QuestionFieldType.multipleChoice ||
      _type == QuestionFieldType.dropdown;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add Question' : 'Edit Question'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _labelController,
                  label: 'Question Prompt *',
                  hintText: 'e.g. GitHub Profile URL or Team Track',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter a question prompt.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<QuestionFieldType>(
                  initialValue: _type,
                  isExpanded: true,
                  dropdownColor: AppColors.surfaceElevated,
                  decoration: const InputDecoration(labelText: 'Field Type'),
                  items: QuestionFieldType.values
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(DynamicFormBuilder._typeLabel(t)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _type = value);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                if (_needsOptions) ...[
                  AppTextField(
                    controller: _optionsController,
                    label: 'Options (comma-separated) *',
                    hintText: 'e.g. Track A, Track B, Track C',
                    minLines: 2,
                    maxLines: 3,
                    validator: (v) {
                      if (!_needsOptions) return null;
                      final parsed = _parseOptions(v ?? '');
                      if (parsed.isEmpty) {
                        return 'Provide at least one option.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                ] else ...[
                  AppTextField(
                    controller: _hintController,
                    label: 'Placeholder / Hint (Optional)',
                    hintText: 'Helpful guidance shown inside the field',
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isRequired,
                  activeThumbColor: AppColors.primary,
                  title: const Text('Required question'),
                  subtitle: const Text(
                    'Students must answer before submitting',
                  ),
                  onChanged: (val) => setState(() => _isRequired = val),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save Question'),
        ),
      ],
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final options = _needsOptions
        ? _parseOptions(_optionsController.text)
        : const <String>[];
    final question = RegistrationQuestion(
      id: widget.existing?.id ?? 'q-${DateTime.now().microsecondsSinceEpoch}',
      label: _labelController.text.trim(),
      type: _type,
      isRequired: _isRequired,
      hintText: _hintController.text.trim().isEmpty
          ? null
          : _hintController.text.trim(),
      options: options,
    );
    Navigator.of(context).pop(question);
  }

  static List<String> _parseOptions(String raw) {
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
