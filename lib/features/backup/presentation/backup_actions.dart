import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/services/file_service.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/backup_codec.dart';
import '../domain/backup_service.dart';
import '../domain/backup_snapshot.dart';
import 'backup_providers.dart';
import 'widgets/import_preview_dialog.dart';

/// UI flows for backups: export, import (validate → preview → merge or
/// replace → Undo) and clear all data (→ Undo).
abstract final class BackupActions {
  static Future<void> export(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final service = ref.read(backupServiceProvider);
    try {
      final json = await service.exportJson();
      await ref.read(fileServiceProvider).saveText(service.fileName(), json);
      if (context.mounted) AppToast.success(context, l10n.backupExported);
    } catch (error, stackTrace) {
      developer.log(
        'Export failed',
        name: 'backup',
        error: error,
        stackTrace: stackTrace,
      );
      if (context.mounted) AppToast.error(context, l10n.backupExportError);
    }
  }

  static Future<void> import(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final service = ref.read(backupServiceProvider);

    final PickedTextFile? file;
    try {
      file = await ref.read(fileServiceProvider).pickText();
    } on FileTooLargeException {
      if (context.mounted) {
        await _showProblem(context, l10n.backupErrorTooLarge);
      }
      return;
    } catch (_) {
      if (context.mounted) AppToast.error(context, l10n.backupReadError);
      return;
    }
    if (file == null || !context.mounted) return;

    final BackupSnapshot incoming;
    try {
      incoming = service.parse(file.content);
    } on BackupFormatException catch (e) {
      if (context.mounted) await _showProblem(context, _describe(l10n, e));
      return;
    }

    if (!context.mounted) return;
    final mode = await showDialog<ImportMode>(
      context: context,
      builder: (_) =>
          ImportPreviewDialog(fileName: file!.name, snapshot: incoming),
    );
    if (mode == null || !context.mounted) return;
    if (mode == ImportMode.replace) {
      final confirmed = await showConfirmDialog(
        context,
        title: l10n.backupReplaceConfirmTitle,
        message: l10n.backupReplaceConfirmMessage,
        confirmLabel: l10n.backupReplace,
        destructive: true,
      );
      if (!confirmed || !context.mounted) return;
    }

    try {
      final previous = await service.import(incoming, mode);
      if (mode == ImportMode.replace) _adoptSettings(ref, incoming);
      if (!context.mounted) return;
      AppToast.success(
        context,
        mode == ImportMode.merge ? l10n.backupMerged : l10n.backupRestored,
        actionLabel: l10n.actionUndo,
        onAction: () => _undo(ref, previous),
      );
    } on AppException {
      if (context.mounted) AppToast.error(context, l10n.backupImportError);
    }
  }

  static Future<void> clearAll(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.backupClearConfirmTitle,
      message: l10n.backupClearConfirmMessage,
      confirmLabel: l10n.backupClear,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      final previous = await ref.read(backupServiceProvider).clearAll();
      if (!context.mounted) return;
      AppToast.success(
        context,
        l10n.backupCleared,
        actionLabel: l10n.actionUndo,
        onAction: () => _undo(ref, previous),
      );
    } on AppException {
      if (context.mounted) AppToast.error(context, l10n.backupClearError);
    }
  }

  static void _undo(WidgetRef ref, BackupSnapshot previous) {
    ref
        .read(backupServiceProvider)
        .restore(previous)
        .then((_) => _adoptSettings(ref, previous))
        .catchError(
          (Object error) =>
              developer.log('Undo failed', name: 'backup', error: error),
        );
  }

  /// The restore wrote the settings; show them without saving again.
  static void _adoptSettings(WidgetRef ref, BackupSnapshot snapshot) =>
      ref.read(settingsControllerProvider.notifier).adopt(snapshot.settings);

  static String _describe(AppLocalizations l10n, BackupFormatException e) =>
      switch (e.problem) {
        BackupProblem.notJson => l10n.backupErrorNotJson,
        BackupProblem.notBackup => l10n.backupErrorNotBackup,
        BackupProblem.newerVersion => l10n.backupErrorNewer,
        BackupProblem.invalidRecords => l10n.backupErrorInvalid(
          e.count,
          e.collection!.label(l10n),
        ),
        BackupProblem.duplicateIds => l10n.backupErrorDuplicates(
          e.collection!.label(l10n),
        ),
      };

  static Future<void> _showProblem(BuildContext context, String message) {
    final l10n = context.l10n;
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.error_outline_rounded, color: context.colors.error),
        title: Text(l10n.backupInvalidTitle),
        content: Text('$message\n\n${l10n.backupNothingChanged}'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.actionClose),
          ),
        ],
      ),
    );
  }
}
