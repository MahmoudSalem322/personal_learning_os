import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/backup_service.dart';
import '../../domain/backup_snapshot.dart';

/// Label of each collection in previews.
extension BackupCollectionLabel on BackupCollection {
  String label(AppLocalizations l10n) => switch (this) {
    BackupCollection.categories => l10n.navCategories,
    BackupCollection.resources => l10n.navResources,
    BackupCollection.notes => l10n.navNotes,
    BackupCollection.tasks => l10n.navTasks,
    BackupCollection.reminders => l10n.notificationsReminders,
    BackupCollection.notifications => l10n.navNotifications,
  };
}

/// Shows what a valid backup contains and asks how to import it. Pops with
/// the chosen [ImportMode], or `null` to cancel.
class ImportPreviewDialog extends StatelessWidget {
  const ImportPreviewDialog({
    required this.fileName,
    required this.snapshot,
    super.key,
  });

  final String fileName;
  final BackupSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = context.textStyles;
    final exportedAt = snapshot.exportedAt;

    return AlertDialog(
      title: Text(l10n.backupImportTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: AppSizes.iconMd,
                    color: colors.mutedText,
                  ),
                  Gap.xs,
                  Expanded(
                    child: Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyStrong,
                    ),
                  ),
                ],
              ),
              if (exportedAt != null) ...[
                Gap.xxs,
                Text(
                  l10n.backupExportedOn(context.formatWhen(exportedAt)),
                  style: text.caption,
                ),
              ],
              Gap.md,
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: AppRadius.chip,
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    for (final c in BackupCollection.values)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xxs,
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(c.label(l10n))),
                            Text(
                              '${snapshot.countOf(c)}',
                              style: text.bodyStrong.copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Gap.md,
              _ModeHint(
                icon: Icons.merge_rounded,
                title: l10n.backupMerge,
                message: l10n.backupMergeHint,
              ),
              Gap.sm,
              _ModeHint(
                icon: Icons.restore_rounded,
                title: l10n.backupReplace,
                message: l10n.backupReplaceHint,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(ImportMode.replace),
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.error,
            side: BorderSide(color: colors.error),
          ),
          child: Text(l10n.backupReplace),
        ),
        FilledButton(
          autofocus: true,
          onPressed: () => Navigator.of(context).pop(ImportMode.merge),
          child: Text(l10n.backupMerge),
        ),
      ],
    );
  }
}

class _ModeHint extends StatelessWidget {
  const _ModeHint({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSizes.iconMd, color: colors.mutedText),
        Gap.xs,
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$title: ', style: text.bodyStrong),
                TextSpan(text: message),
              ],
            ),
            style: text.body.copyWith(color: colors.mutedText),
          ),
        ),
      ],
    );
  }
}
