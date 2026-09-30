import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_info.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../backup/presentation/backup_actions.dart';
import '../../../notifications/presentation/widgets/notification_preferences_dialog.dart';
import '../../../search/presentation/global_search_dialog.dart';
import '../settings_controller.dart';
import '../widgets/language_selector.dart';
import '../widgets/theme_mode_selector.dart';

/// Preferences, data management (backup, import, clear) and about.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final notificationsOn = ref.watch(
      settingsControllerProvider.select((s) => s.notifications.enabled),
    );
    final volatile = ref.watch(storageStatusProvider) == StorageStatus.volatile;

    return AppPage(
      title: l10n.navSettings,
      subtitle: l10n.settingsSubtitle,
      body: Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              _Section(
                title: l10n.settingsAppearance,
                children: [
                  _Row(
                    icon: Icons.contrast_rounded,
                    title: l10n.themeLabel,
                    trailing: const SizedBox(
                      width: 200,
                      child: ThemeModeSelector(),
                    ),
                  ),
                  _Row(
                    icon: Icons.translate_rounded,
                    title: l10n.languageLabel,
                    trailing: const SizedBox(
                      width: 200,
                      child: LanguageSelector(),
                    ),
                  ),
                ],
              ),
              _Section(
                title: l10n.navNotifications,
                children: [
                  _Row(
                    icon: notificationsOn
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    title: l10n.notificationPreferences,
                    subtitle: notificationsOn
                        ? l10n.settingsNotificationsOn
                        : l10n.settingsNotificationsOff,
                    trailing: OutlinedButton(
                      onPressed: () => showNotificationPreferences(context),
                      child: Text(l10n.settingsChange),
                    ),
                  ),
                ],
              ),
              _Section(
                title: l10n.settingsData,
                children: [
                  if (volatile) const _VolatileWarning(),
                  _Row(
                    icon: Icons.download_rounded,
                    title: l10n.backupExport,
                    subtitle: l10n.backupExportHint,
                    trailing: FilledButton(
                      onPressed: () => BackupActions.export(context, ref),
                      child: Text(l10n.backupExportAction),
                    ),
                  ),
                  _Row(
                    icon: Icons.upload_file_rounded,
                    title: l10n.backupImport,
                    subtitle: l10n.backupImportHint,
                    trailing: OutlinedButton(
                      onPressed: () => BackupActions.import(context, ref),
                      child: Text(l10n.backupImportAction),
                    ),
                  ),
                  _Row(
                    icon: Icons.delete_forever_outlined,
                    iconColor: context.colors.error,
                    title: l10n.backupClear,
                    subtitle: l10n.backupClearHint,
                    trailing: OutlinedButton(
                      onPressed: () => BackupActions.clearAll(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.error,
                        side: BorderSide(color: context.colors.error),
                      ),
                      child: Text(l10n.backupClearAction),
                    ),
                  ),
                ],
              ),
              // Phones rarely have a keyboard.
              if (!context.screenSize.isMobile)
                _Section(
                  title: l10n.settingsShortcuts,
                  children: [
                    _Shortcut(
                      keys: [searchShortcutLabel()],
                      label: l10n.shortcutSearch,
                    ),
                    _Shortcut(keys: const ['N'], label: l10n.shortcutNewItem),
                    _Shortcut(keys: const ['Esc'], label: l10n.shortcutClose),
                  ],
                ),
              _Section(title: l10n.settingsAbout, children: const [_About()]),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppSpacing.xxs,
              bottom: AppSpacing.xs,
            ),
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: context.textStyles.overline.copyWith(
                  color: context.colors.mutedText,
                ),
              ),
            ),
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A setting: icon, title, optional explanation and a control. The control
/// moves under the text on narrow screens.
class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.trailing,
    this.subtitle,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final label = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSizes.iconMd, color: iconColor ?? colors.mutedText),
        Gap.sm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: text.bodyStrong),
              if (subtitle != null) ...[
                Gap.xxs,
                Text(
                  subtitle!,
                  style: text.caption.copyWith(color: colors.mutedText),
                ),
              ],
            ],
          ),
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 520) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                label,
                Gap.sm,
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: trailing,
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: label),
              Gap.md,
              trailing,
            ],
          );
        },
      ),
    );
  }
}

/// One keyboard shortcut: its keys and what it does.
class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.keys, required this.label});

  final List<String> keys;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(label, style: context.textStyles.body)),
          Gap.md,
          Wrap(
            spacing: AppSpacing.xxs,
            children: [for (final key in keys) KeyCap(label: key)],
          ),
        ],
      ),
    );
  }
}

class _VolatileWarning extends StatelessWidget {
  const _VolatileWarning();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.warningSoft,
        borderRadius: AppRadius.chip,
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: AppSizes.iconMd,
            color: colors.warning,
          ),
          Gap.sm,
          Expanded(child: Text(context.l10n.backupVolatileWarning)),
        ],
      ),
    );
  }
}

class _About extends StatelessWidget {
  const _About();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.textStyles;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLogo(),
          Gap.sm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.appTitle, style: text.titleSmall),
                Text(
                  l10n.settingsVersion(AppInfo.version),
                  style: text.caption,
                ),
                Gap.xs,
                Text(
                  l10n.settingsAboutMessage,
                  style: text.body.copyWith(color: context.colors.mutedText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
