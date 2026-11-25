import 'package:flutter/material.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/media_preview_dialog.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

/// Reusable organizer media library manager supporting add, preview, ordering, and delete.
class MediaManagerWidget extends StatelessWidget {
  const MediaManagerWidget({
    super.key,
    required this.items,
    required this.onChanged,
    this.title = 'Media Library & Ordering',
  });

  final List<MediaItem> items;
  final ValueChanged<List<MediaItem>> onChanged;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ordered = [...items]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

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
                Text(title, style: theme.textTheme.titleMedium),
                Text(
                  '${ordered.length} media item${ordered.length == 1 ? '' : 's'} · drag or reorder display sequence',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            AppButton(
              label: 'Add Media',
              size: AppButtonSize.sm,
              variant: AppButtonVariant.outline,
              leadingIcon: Icons.add_photo_alternate_outlined,
              onPressed: () => _openAddMediaDialog(context, ordered),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (ordered.isEmpty)
          AppCard(
            elevated: true,
            child: Text(
              'No gallery photos, promotional videos, or recap media added yet.',
              style: theme.textTheme.bodySmall,
            ),
          )
        else
          Column(
            children: List.generate(ordered.length, (index) {
              final item = ordered[index];
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadii.borderMd,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => item.kind == MediaKind.video
                          ? showVideoEmbedDialog(context, item)
                          : showMediaPreviewDialog(
                              context,
                              item,
                              gallery: ordered,
                            ),
                      borderRadius: AppRadii.borderSm,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CampusNetworkImage(
                            imageUrl: item.thumbnailUrl ?? item.url,
                            width: 72,
                            height: 52,
                            borderRadius: AppRadii.borderSm,
                          ),
                          if (item.kind == MediaKind.video)
                            const Icon(
                              Icons.play_circle_filled_rounded,
                              color: AppColors.textPrimary,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.caption,
                            style: theme.textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '#${index + 1} · ${item.section.label} · ${item.kind.label}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Move up',
                      onPressed: index == 0
                          ? null
                          : () => _reorder(ordered, index, index - 1),
                      icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Move down',
                      onPressed: index == ordered.length - 1
                          ? null
                          : () => _reorder(ordered, index, index + 1),
                      icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Remove media',
                      onPressed: () {
                        final next = List<MediaItem>.from(ordered)
                          ..removeAt(index);
                        onChanged(_reindex(next));
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
      ],
    );
  }

  void _reorder(List<MediaItem> ordered, int from, int to) {
    final next = List<MediaItem>.from(ordered);
    final moved = next.removeAt(from);
    next.insert(to, moved);
    onChanged(_reindex(next));
  }

  List<MediaItem> _reindex(List<MediaItem> list) {
    return [
      for (var i = 0; i < list.length; i++) list[i].copyWith(orderIndex: i),
    ];
  }

  Future<void> _openAddMediaDialog(
    BuildContext context,
    List<MediaItem> ordered,
  ) async {
    final formKey = GlobalKey<FormState>();
    final captionCtrl = TextEditingController();
    final urlCtrl = TextEditingController(
      text: 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?auto=format&fit=crop&w=1000&q=80',
    );
    var kind = MediaKind.photo;
    var section = MediaSection.gallery;

    final added = await showDialog<MediaItem>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Media Asset'),
          content: SizedBox(
            width: 440,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<MediaSection>(
                    initialValue: section,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceElevated,
                    decoration: const InputDecoration(labelText: 'Section'),
                    items: MediaSection.values
                        .map(
                          (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => section = v);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<MediaKind>(
                    initialValue: kind,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceElevated,
                    decoration: const InputDecoration(labelText: 'Media Type'),
                    items: MediaKind.values
                        .map(
                          (k) => DropdownMenuItem(value: k, child: Text(k.label)),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => kind = v);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: captionCtrl,
                    label: 'Caption / Title *',
                    hintText: 'e.g. Opening keynote at Main Auditorium',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Caption is required.'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: urlCtrl,
                    label: 'Media URL *',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'URL is required.'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                Navigator.of(dialogContext).pop(
                  MediaItem(
                    id: 'media-${DateTime.now().microsecondsSinceEpoch}',
                    url: urlCtrl.text.trim(),
                    caption: captionCtrl.text.trim(),
                    kind: kind,
                    section: section,
                    orderIndex: ordered.length,
                    thumbnailUrl: kind == MediaKind.video
                        ? 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=1000&q=80'
                        : null,
                    durationLabel: kind == MediaKind.video ? '01:45' : null,
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    captionCtrl.dispose();
    urlCtrl.dispose();
    if (added == null) return;
    onChanged([...ordered, added]);
  }
}
