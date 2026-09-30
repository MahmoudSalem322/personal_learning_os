import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/system_notifier.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../../../settings/presentation/widgets/preference_feedback.dart';
import '../../domain/notification_preferences.dart';

Future<void> showNotificationPreferences(BuildContext context) =>
    showDialog<void>(
      context: context,
      builder: (_) => const NotificationPreferencesDialog(),
    );

/// Which notifications to create. Changes are saved immediately.
class NotificationPreferencesDialog extends ConsumerWidget {
  const NotificationPreferencesDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final prefs = ref.watch(
      settingsControllerProvider.select((s) => s.notifications),
    );
    final notifier = ref.watch(systemNotifierProvider);

    Future<void> save(NotificationPreferences next) => applyPreference(
      context,
      () => ref
          .read(settingsControllerProvider.notifier)
          .setNotificationPreferences(next),
    );

    Widget toggle({
      required String title,
      required String subtitle,
      required bool value,
      required ValueChanged<bool> onChanged,
      bool enabled = true,
    }) => SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: enabled ? onChanged : null,
    );

    return AlertDialog(
      title: Text(l10n.notificationPreferences),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            toggle(
              title: l10n.notificationPrefEnabled,
              subtitle: l10n.notificationPrefEnabledHint,
              value: prefs.enabled,
              onChanged: (v) => save(prefs.copyWith(enabled: v)),
            ),
            const Divider(height: AppSpacing.lg),
            toggle(
              title: l10n.notificationPrefReminders,
              subtitle: l10n.notificationPrefRemindersHint,
              value: prefs.reminders,
              enabled: prefs.enabled,
              onChanged: (v) => save(prefs.copyWith(reminders: v)),
            ),
            toggle(
              title: l10n.notificationPrefUpcoming,
              subtitle: l10n.notificationPrefUpcomingHint,
              value: prefs.upcomingTasks,
              enabled: prefs.enabled,
              onChanged: (v) => save(prefs.copyWith(upcomingTasks: v)),
            ),
            toggle(
              title: l10n.notificationPrefOverdue,
              subtitle: l10n.notificationPrefOverdueHint,
              value: prefs.overdueTasks,
              enabled: prefs.enabled,
              onChanged: (v) => save(prefs.copyWith(overdueTasks: v)),
            ),
            if (notifier.isSupported) ...[
              const Divider(height: AppSpacing.lg),
              toggle(
                title: l10n.notificationPrefBrowser,
                subtitle: l10n.notificationPrefBrowserHint,
                value: prefs.browser && notifier.isAllowed,
                enabled: prefs.enabled,
                onChanged: (v) async {
                  if (v && !await notifier.requestPermission()) {
                    if (context.mounted) {
                      AppToast.error(context, l10n.notificationBrowserBlocked);
                    }
                    return;
                  }
                  await save(prefs.copyWith(browser: v));
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionClose),
        ),
      ],
    );
  }
}
