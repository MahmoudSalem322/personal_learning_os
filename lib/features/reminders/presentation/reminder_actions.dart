import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/widgets/app_toast.dart';
import '../domain/reminder.dart';
import 'reminders_providers.dart';
import 'widgets/reminder_form_dialog.dart';

/// UI flows for reminders: form, pause/resume, delete + Undo.
abstract final class ReminderActions {
  /// Opens the form to add a reminder (for [target]/[targetId]) or edit
  /// [reminder]. Returns the saved reminder.
  static Future<Reminder?> openForm(
    BuildContext context, {
    Reminder? reminder,
    ReminderTarget target = ReminderTarget.session,
    String? targetId,
    String? targetTitle,
  }) async {
    final saved = await showDialog<Reminder>(
      context: context,
      builder: (_) => ReminderFormDialog(
        reminder: reminder,
        target: target,
        targetId: targetId,
        targetTitle: targetTitle,
      ),
    );
    if (saved != null && context.mounted) {
      AppToast.success(
        context,
        context.l10n.reminderSetFor(context.formatWhen(saved.remindAt)),
      );
    }
    return saved;
  }

  static Future<void> setEnabled(
    BuildContext context,
    WidgetRef ref,
    Reminder reminder, {
    required bool enabled,
  }) async {
    try {
      await ref
          .read(reminderServiceProvider)
          .setEnabled(reminder.id, enabled: enabled);
    } on AppException {
      if (context.mounted) {
        AppToast.error(context, context.l10n.reminderSaveError);
      }
    }
  }

  /// Deletes right away and offers Undo (a reminder is cheap to recreate,
  /// so no confirmation dialog).
  static Future<void> delete(
    BuildContext context,
    WidgetRef ref,
    Reminder reminder,
  ) async {
    final l10n = context.l10n;
    final service = ref.read(reminderServiceProvider);
    try {
      final deleted = await service.delete(reminder.id);
      if (!context.mounted) return;
      AppToast.success(
        context,
        l10n.reminderDeleted,
        actionLabel: l10n.actionUndo,
        onAction: () => service
            .restore(deleted)
            .catchError(
              (Object error) => developer.log(
                'Undo delete failed',
                name: 'reminders',
                error: error,
              ),
            ),
      );
    } on NotFoundException {
      return;
    } on AppException {
      if (context.mounted) AppToast.error(context, l10n.reminderDeleteError);
    }
  }
}
