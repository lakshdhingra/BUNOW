import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/organizer_studio/domain/models/organizer_models.dart';
import 'package:bennett_campus/features/organizer_studio/presentation/providers/organizer_providers.dart';
import 'package:bennett_campus/features/organizer_studio/presentation/widgets/media_manager_widget.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Organizer Club Management page for profile editing and representative permissions.
class OrganizerClubManagementPage extends ConsumerStatefulWidget {
  const OrganizerClubManagementPage({super.key});

  @override
  ConsumerState<OrganizerClubManagementPage> createState() =>
      _OrganizerClubManagementPageState();
}

class _OrganizerClubManagementPageState
    extends ConsumerState<OrganizerClubManagementPage> {
  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _taglineController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _coverUrlController = TextEditingController();

  String? _hydratedClubId;
  bool _isSavingProfile = false;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _taglineController.dispose();
    _aboutController.dispose();
    _coverUrlController.dispose();
    super.dispose();
  }

  void _syncClubControllers(CampusClub club) {
    if (_hydratedClubId == club.id) return;
    _hydratedClubId = club.id;
    _nameController.text = club.name;
    _categoryController.text = club.category;
    _taglineController.text = club.tagline;
    _aboutController.text = club.about;
    _coverUrlController.text = club.coverUrl;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeClub = ref.watch(activeOrganizerClubProvider);
    final repsAsync = ref.watch(clubRepresentativesControllerProvider);

    if (activeClub == null) {
      return const AppLoadingIndicator(message: 'Loading club workspace...');
    }
    _syncClubControllers(activeClub);

    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Club Management & Access',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 2),
            Text(
              'Update ${activeClub.name} branding and manage authorized club representatives.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              child: Form(
                key: _profileFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Club Profile', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.md),
                    ResponsiveCardGrid(
                      desktopColumns: 2,
                      tabletColumns: 2,
                      mobileColumns: 1,
                      children: [
                        AppTextField(
                          controller: _nameController,
                          label: 'Club Name *',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Name is required.'
                              : null,
                        ),
                        AppTextField(
                          controller: _categoryController,
                          label: 'Category *',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Category is required.'
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _taglineController,
                      label: 'Short Tagline *',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Tagline is required.'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _aboutController,
                      label: 'About Club *',
                      minLines: 3,
                      maxLines: 5,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'About description is required.'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _coverUrlController,
                      label: 'Cover Image URL',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Save Club Profile',
                      leadingIcon: Icons.save_outlined,
                      isLoading: _isSavingProfile,
                      onPressed: () => _saveClubProfile(activeClub),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
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
                            'Authorized Representatives',
                            style: theme.textTheme.headlineSmall,
                          ),
                          Text(
                            'Manage which Bennett student accounts can edit events or export rosters.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      AppButton(
                        label: 'Add Representative',
                        size: AppButtonSize.sm,
                        leadingIcon: Icons.person_add_alt_1_outlined,
                        onPressed: () => _openAddRepDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadii.borderMd,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.security_outlined,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'UI Permission Preview: Role badges below reflect club authorization levels. Real permission enforcement will be handled server-side by Supabase RLS policies.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  repsAsync.when(
                    loading: () => const AppLoadingIndicator(centered: false),
                    error: (e, _) => AppErrorWidget(
                      message: e.toString(),
                      compact: true,
                    ),
                    data: (reps) {
                      return Column(
                        children: reps.map((rep) {
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
                                  constraints: const BoxConstraints(maxWidth: 320),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: AppColors.primaryMuted,
                                        child: Text(
                                          rep.initials,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                color: AppColors.primaryHover,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              rep.name,
                                              style: theme.textTheme.titleSmall,
                                            ),
                                            Text(
                                              rep.email,
                                              style: theme.textTheme.bodySmall,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              rep.program,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: AppColors.textMuted,
                                                  ),
                                            ),
                                          ],
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
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 180,
                                      ),
                                      child:
                                          DropdownButtonFormField<OrganizerRole>(
                                            initialValue: rep.role,
                                            isExpanded: true,
                                            dropdownColor:
                                                AppColors.surfaceElevated,
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: AppSpacing.sm,
                                                    vertical: AppSpacing.xs + 2,
                                                  ),
                                            ),
                                            items: OrganizerRole.values
                                                .map(
                                                  (role) => DropdownMenuItem(
                                                    value: role,
                                                    child: Text(role.label),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (nextRole) {
                                              if (nextRole == null) return;
                                              ref
                                                  .read(
                                                    clubRepresentativesControllerProvider
                                                        .notifier,
                                                  )
                                                  .updateRole(
                                                    representativeId: rep.id,
                                                    role: nextRole,
                                                  );
                                            },
                                          ),
                                    ),
                                    if (rep.role != OrganizerRole.owner)
                                      IconButton(
                                        tooltip: 'Remove representative',
                                        onPressed: () => ref
                                            .read(
                                              clubRepresentativesControllerProvider
                                                  .notifier,
                                            )
                                            .removeRepresentative(rep.id),
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: AppColors.error,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              child: MediaManagerWidget(
                title: 'Club Media Library & Ordering',
                items: activeClub.photos,
                onChanged: (updatedPhotos) =>
                    _updateClubMedia(activeClub, updatedPhotos),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              elevated: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Role Permissions Matrix', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  ...OrganizerRole.values.map((role) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              role.label,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              role.summary,
                              style: theme.textTheme.bodySmall,
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
        ),
      ),
    );
  }

  Future<void> _saveClubProfile(CampusClub club) async {
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;
    setState(() => _isSavingProfile = true);

    final updated = CampusClub(
      id: club.id,
      name: _nameController.text.trim(),
      shortCode: club.shortCode,
      category: _categoryController.text.trim(),
      tagline: _taglineController.text.trim(),
      about: _aboutController.text.trim(),
      memberCount: club.memberCount,
      upcomingEventCount: club.upcomingEventCount,
      coverUrl: _coverUrlController.text.trim().isEmpty
          ? club.coverUrl
          : _coverUrlController.text.trim(),
      logoUrl: club.logoUrl,
      isVerified: club.isVerified,
      socialLinks: club.socialLinks,
      leadership: club.leadership,
      previousEvents: club.previousEvents,
      photos: club.photos,
      videos: club.videos,
    );

    await ref.read(authorizedClubsProvider.notifier).updateClub(updated);
    if (!mounted) return;
    setState(() => _isSavingProfile = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updated profile for ${updated.name}.')),
    );
  }

  Future<void> _updateClubMedia(
    CampusClub club,
    List<MediaItem> updatedPhotos,
  ) async {
    final updated = CampusClub(
      id: club.id,
      name: club.name,
      shortCode: club.shortCode,
      category: club.category,
      tagline: club.tagline,
      about: club.about,
      memberCount: club.memberCount,
      upcomingEventCount: club.upcomingEventCount,
      coverUrl: club.coverUrl,
      logoUrl: club.logoUrl,
      isVerified: club.isVerified,
      socialLinks: club.socialLinks,
      leadership: club.leadership,
      previousEvents: club.previousEvents,
      photos: updatedPhotos,
      videos: club.videos,
    );
    await ref.read(authorizedClubsProvider.notifier).updateClub(updated);
  }

  Future<void> _openAddRepDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final programCtrl = TextEditingController(text: 'B.Tech CSE · Year 3');
    var role = OrganizerRole.eventManager;

    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Club Representative'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: nameCtrl,
                    label: 'Student Name *',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name is required.'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: emailCtrl,
                    label: 'Bennett Email *',
                    hintText: 'e23cseu0000@bennett.edu.in',
                    validator: (v) {
                      final trimmed = v?.trim() ?? '';
                      if (trimmed.isEmpty || !trimmed.endsWith('@bennett.edu.in')) {
                        return 'Use a @bennett.edu.in email.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: programCtrl,
                    label: 'Program & Year',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<OrganizerRole>(
                    initialValue: role,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceElevated,
                    decoration: const InputDecoration(labelText: 'Assigned Role'),
                    items: OrganizerRole.values
                        .where((r) => r != OrganizerRole.owner)
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setDialogState(() => role = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (added == true) {
      await ref
          .read(clubRepresentativesControllerProvider.notifier)
          .addRepresentative(
            name: nameCtrl.text.trim(),
            email: emailCtrl.text.trim(),
            program: programCtrl.text.trim(),
            role: role,
          );
    }

    nameCtrl.dispose();
    emailCtrl.dispose();
    programCtrl.dispose();
  }
}
