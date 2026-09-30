import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../reminders/domain/reminder.dart';
import '../../../reminders/presentation/reminder_actions.dart';
import '../../../reminders/presentation/reminders_providers.dart';
import '../../../reminders/presentation/widgets/reminder_tile.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../../domain/app_notification.dart';
import '../notification_actions.dart';
import '../notifications_providers.dart';
import '../widgets/notification_preferences_dialog.dart';
import '../widgets/notification_tile.dart';

enum _Tab { inbox, reminders }

/// Inbox of in-app notifications, and the list of reminders.
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  _Tab _tab = _Tab.inbox;
  bool _unreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unread = ref.watch(unreadCountProvider);
    final hasInbox = ref.watch(inboxProvider).value?.isNotEmpty ?? false;

    return AppPage(
      title: l10n.navNotifications,
      subtitle: l10n.notificationsSubtitle,
      actions: [
        if (_tab == _Tab.inbox) ...[
          if (unread > 0)
            TextButton.icon(
              onPressed: () => NotificationActions.markAllRead(context, ref),
              icon: const Icon(Icons.done_all_rounded, size: AppSizes.iconMd),
              label: Text(l10n.notificationsMarkAllRead),
            ),
          if (hasInbox)
            IconButton(
              tooltip: l10n.notificationsClearAll,
              onPressed: () => NotificationActions.clearAll(context, ref),
              icon: const Icon(Icons.clear_all_rounded, size: AppSizes.iconMd),
            ),
        ] else
          FilledButton.icon(
            onPressed: () => ReminderActions.openForm(context),
            icon: const Icon(Icons.add_alarm_rounded, size: AppSizes.iconMd),
            label: Text(l10n.remindersNew),
          ),
        IconButton(
          tooltip: l10n.notificationPreferences,
          onPressed: () => showNotificationPreferences(context),
          icon: const Icon(Icons.tune_rounded, size: AppSizes.iconMd),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SegmentedButton<_Tab>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: _Tab.inbox,
                  icon: const Icon(Icons.inbox_outlined, size: AppSizes.iconSm),
                  label: Text(
                    unread == 0
                        ? l10n.notificationsInbox
                        : '${l10n.notificationsInbox} ($unread)',
                  ),
                ),
                ButtonSegment(
                  value: _Tab.reminders,
                  icon: const Icon(Icons.alarm_rounded, size: AppSizes.iconSm),
                  label: Text(l10n.notificationsReminders),
                ),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => setState(() => _tab = s.first),
            ),
          ),
          Gap.md,
          const _DisabledBanner(),
          Expanded(
            child: switch (_tab) {
              _Tab.inbox => _Inbox(
                unreadOnly: _unreadOnly,
                onUnreadOnlyChanged: (v) => setState(() => _unreadOnly = v),
              ),
              _Tab.reminders => const _Reminders(),
            },
          ),
        ],
      ),
    );
  }
}

/// Shown when notifications are turned off, with a quick way back on.
class _DisabledBanner extends ConsumerWidget {
  const _DisabledBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final enabled = ref.watch(
      settingsControllerProvider.select((s) => s.notifications.enabled),
    );
    if (enabled) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.warningSoft,
          borderRadius: AppRadius.card,
        ),
        child: Row(
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: AppSizes.iconMd,
              color: colors.warning,
            ),
            Gap.sm,
            Expanded(child: Text(l10n.notificationsOffMessage)),
            TextButton(
              onPressed: () => showNotificationPreferences(context),
              child: Text(l10n.notificationPreferences),
            ),
          ],
        ),
      ),
    );
  }
}

class _Inbox extends ConsumerWidget {
  const _Inbox({required this.unreadOnly, required this.onUnreadOnlyChanged});

  final bool unreadOnly;
  final ValueChanged<bool> onUnreadOnlyChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ref
        .watch(inboxProvider)
        .when(
          loading: () => const _Skeleton(),
          error: (_, _) => AppStateView.error(
            context: context,
            onRetry: () => ref.invalidate(notificationsProvider),
          ),
          data: (all) {
            if (all.isEmpty) {
              return AppStateView(
                icon: Icons.notifications_none_rounded,
                title: l10n.notificationsEmptyTitle,
                message: l10n.notificationsEmptyMessage,
              );
            }
            final visible = unreadOnly
                ? [
                    for (final n in all)
                      if (!n.isRead) n,
                  ]
                : all;
            final groups = _group(visible, DateTime.now());
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    ChoiceChip(
                      label: Text(l10n.notificationsFilterAll),
                      selected: !unreadOnly,
                      showCheckmark: false,
                      onSelected: (_) => onUnreadOnlyChanged(false),
                    ),
                    ChoiceChip(
                      label: Text(l10n.notificationsFilterUnread),
                      selected: unreadOnly,
                      showCheckmark: false,
                      onSelected: (_) => onUnreadOnlyChanged(true),
                    ),
                  ],
                ),
                Gap.md,
                Expanded(
                  child: visible.isEmpty
                      ? AppStateView(
                          icon: Icons.done_all_rounded,
                          title: l10n.notificationsAllReadTitle,
                          message: l10n.notificationsAllReadMessage,
                        )
                      : ListView(
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          children: [
                            for (final (label, items) in [
                              (l10n.notificationsToday, groups.today),
                              (l10n.notificationsEarlier, groups.earlier),
                            ])
                              if (items.isNotEmpty) ...[
                                _GroupLabel(label),
                                AppCard(
                                  padding: const EdgeInsets.all(AppSpacing.xxs),
                                  child: Column(
                                    children: [
                                      for (final n in items)
                                        NotificationTile(
                                          key: ValueKey(n.id),
                                          notification: n,
                                        ),
                                    ],
                                  ),
                                ),
                                Gap.md,
                              ],
                          ],
                        ),
                ),
              ],
            );
          },
        );
  }

  static ({List<AppNotification> today, List<AppNotification> earlier}) _group(
    List<AppNotification> items,
    DateTime now,
  ) {
    final start = DateTime(now.year, now.month, now.day);
    return (
      today: [
        for (final n in items)
          if (!n.createdAt.isBefore(start)) n,
      ],
      earlier: [
        for (final n in items)
          if (n.createdAt.isBefore(start)) n,
      ],
    );
  }
}

class _Reminders extends ConsumerWidget {
  const _Reminders();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ref
        .watch(remindersProvider)
        .when(
          loading: () => const _Skeleton(),
          error: (_, _) => AppStateView.error(
            context: context,
            onRetry: () => ref.invalidate(remindersProvider),
          ),
          data: (all) {
            if (all.isEmpty) {
              return AppStateView(
                icon: Icons.alarm_add_rounded,
                title: l10n.remindersEmptyTitle,
                message: l10n.remindersEmptyMessage,
                action: FilledButton.icon(
                  onPressed: () => ReminderActions.openForm(context),
                  icon: const Icon(
                    Icons.add_alarm_rounded,
                    size: AppSizes.iconMd,
                  ),
                  label: Text(l10n.remindersNew),
                ),
              );
            }
            final upcoming = [
              for (final r in all)
                if (!r.isFinished) r,
            ];
            final past = [
              for (final r in all.reversed)
                if (r.isFinished) r,
            ];
            Widget section(String label, List<Reminder> items) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GroupLabel(label),
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Column(
                    children: [
                      for (final r in items)
                        ReminderTile(key: ValueKey(r.id), reminder: r),
                    ],
                  ),
                ),
                Gap.md,
              ],
            );
            return ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              children: [
                if (upcoming.isNotEmpty)
                  section(l10n.remindersUpcoming, upcoming),
                if (past.isNotEmpty) section(l10n.remindersPast, past),
              ],
            );
          },
        );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.xxs,
        bottom: AppSpacing.xs,
      ),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: context.textStyles.overline.copyWith(
            color: context.colors.mutedText,
          ),
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, _) => Gap.xs,
      itemBuilder: (_, _) =>
          const AppSkeleton(height: 64, borderRadius: AppRadius.card),
    );
  }
}
