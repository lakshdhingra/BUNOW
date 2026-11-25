import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bennett_campus/core/router/app_routes.dart';
import 'package:bennett_campus/core/theme/app_colors.dart';
import 'package:bennett_campus/core/theme/app_radii.dart';
import 'package:bennett_campus/core/theme/app_spacing.dart';
import 'package:bennett_campus/features/student_portal/domain/models/campus_models.dart';
import 'package:bennett_campus/features/student_portal/presentation/providers/student_portal_providers.dart';
import 'package:bennett_campus/features/student_portal/presentation/widgets/category_chip.dart';
import 'package:bennett_campus/shared/widgets/widgets.dart';

enum _NotificationFilter {
  all('All'),
  unread('Unread'),
  events('Events'),
  registrations('Registrations'),
  reminders('Reminders'),
  announcements('Announcements');

  const _NotificationFilter(this.label);
  final String label;
}

/// Student Notification Center with read/unread toggles, filtering, and deep links.
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  _NotificationFilter _filter = _NotificationFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationsAsync = ref.watch(notificationsControllerProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

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
                      'Notification Center',
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$unreadCount unread campus update${unreadCount == 1 ? '' : 's'}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                AppButton(
                  label: 'Mark All as Read',
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.sm,
                  leadingIcon: Icons.done_all_rounded,
                  onPressed: unreadCount == 0
                      ? null
                      : () => ref
                            .read(notificationsControllerProvider.notifier)
                            .markAllAsRead(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _NotificationFilter.values.map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: CategoryChip(
                      label: f.label,
                      isSelected: _filter == f,
                      onTap: () => setState(() => _filter = f),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            notificationsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: AppLoadingIndicator(message: 'Loading notifications...'),
              ),
              error: (error, _) => AppErrorWidget(
                message: error.toString(),
                onRetry: () => ref.invalidate(notificationsControllerProvider),
              ),
              data: (notifications) {
                final filtered = notifications.where((item) {
                  return switch (_filter) {
                    _NotificationFilter.all => true,
                    _NotificationFilter.unread => item.isUnread,
                    _NotificationFilter.events =>
                      item.type == NotificationType.newEventPublished ||
                          item.type == NotificationType.eventChanges,
                    _NotificationFilter.registrations =>
                      item.type == NotificationType.registrationConfirmation,
                    _NotificationFilter.reminders =>
                      item.type == NotificationType.eventReminder ||
                          item.type == NotificationType.deadlineReminder,
                    _NotificationFilter.announcements =>
                      item.type == NotificationType.clubAnnouncement,
                  };
                }).toList();

                if (filtered.isEmpty) {
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          size: 32,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'No notifications in ${_filter.label}',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'You are all caught up on campus announcements and reminders.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: filtered.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _NotificationCard(
                        notification: item,
                        onOpenTarget: () => _openAssociatedTarget(item),
                        onToggleRead: () {
                          final notifier = ref.read(
                            notificationsControllerProvider.notifier,
                          );
                          if (item.isUnread) {
                            notifier.markAsRead(item.id);
                          } else {
                            notifier.markAsUnread(item.id);
                          }
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

  Future<void> _openAssociatedTarget(CampusNotification item) async {
    if (item.isUnread) {
      await ref
          .read(notificationsControllerProvider.notifier)
          .markAsRead(item.id);
    }
    if (!mounted) return;
    if (item.registrationId != null) {
      context.go(AppRoutes.ticketDetail(item.registrationId!));
    } else if (item.eventId != null) {
      context.go(AppRoutes.eventDetail(item.eventId!));
    } else if (item.clubId != null) {
      context.go(AppRoutes.clubProfile(item.clubId!));
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onOpenTarget,
    required this.onToggleRead,
  });

  final CampusNotification notification;
  final VoidCallback onOpenTarget;
  final VoidCallback onToggleRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _accentFor(notification.type);
    final hasTarget =
        notification.eventId != null ||
        notification.clubId != null ||
        notification.registrationId != null;

    return AppCard(
      elevated: notification.isUnread,
      borderColor: notification.isUnread
          ? AppColors.primary.withValues(alpha: 0.45)
          : AppColors.border,
      onTap: hasTarget ? onOpenTarget : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: AppRadii.borderMd,
            ),
            child: Icon(_iconFor(notification.type), size: 20, color: accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: AppRadii.borderPill,
                      ),
                      child: Text(
                        notification.type.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accent,
                        ),
                      ),
                    ),
                    Text(notification.timeAgo, style: theme.textTheme.labelSmall),
                    if (notification.isUnread)
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(notification.title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(notification.body, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    if (hasTarget)
                      TextButton(
                        onPressed: onOpenTarget,
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          notification.registrationId != null
                              ? 'Open Ticket'
                              : (notification.eventId != null
                                    ? 'View Event'
                                    : 'View Club'),
                        ),
                      ),
                    TextButton(
                      onPressed: onToggleRead,
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        notification.isUnread ? 'Mark as read' : 'Mark unread',
                      ),
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

  static Color _accentFor(NotificationType type) {
    return switch (type) {
      NotificationType.newEventPublished => AppColors.primaryHover,
      NotificationType.registrationConfirmation => AppColors.success,
      NotificationType.eventReminder => AppColors.secondary,
      NotificationType.eventChanges => AppColors.warning,
      NotificationType.deadlineReminder => AppColors.error,
      NotificationType.clubAnnouncement => AppColors.primary,
    };
  }

  static IconData _iconFor(NotificationType type) {
    return switch (type) {
      NotificationType.newEventPublished => Icons.campaign_outlined,
      NotificationType.registrationConfirmation =>
        Icons.confirmation_number_outlined,
      NotificationType.eventReminder => Icons.alarm_outlined,
      NotificationType.eventChanges => Icons.edit_calendar_outlined,
      NotificationType.deadlineReminder => Icons.hourglass_bottom_rounded,
      NotificationType.clubAnnouncement => Icons.forum_outlined,
    };
  }
}
