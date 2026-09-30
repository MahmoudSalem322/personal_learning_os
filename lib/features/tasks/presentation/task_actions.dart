import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/app_toast.dart';
import '../domain/task.dart';
import 'tasks_providers.dart';
import 'widgets/task_form_dialog.dart';

/// UI flows for tasks: form, quick status changes, delete + Undo.
abstract final class TaskActions {
  /// Opens the create form (or edit form for [task]). [categoryId] and
  /// [resourceId] pre-select links for new tasks. Returns the saved task.
  static Future<Task?> openForm(
    BuildContext context, {
    Task? task,
    String? categoryId,
    String? resourceId,
  }) async {
    final saved = await showDialog<Task>(
      context: context,
      builder: (_) => TaskFormDialog(
        task: task,
        initialCategoryId: categoryId,
        initialResourceId: resourceId,
      ),
    );
    if (saved != null && context.mounted) {
      AppToast.success(
        context,
        task == null ? context.l10n.taskCreated : context.l10n.taskUpdated,
      );
    }
    return saved;
  }

  /// One-tap status change from menus and the detail page.
  static Future<void> setStatus(
    BuildContext context,
    WidgetRef ref,
    Task task,
    TaskStatus status,
  ) => _run(
    context,
    () => ref.read(taskServiceProvider).setStatus(task.id, status),
  );

  /// Checkbox toggle: completed ↔ todo.
  static Future<void> toggleCompleted(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) => _run(
    context,
    () => ref.read(taskServiceProvider).toggleCompleted(task.id),
  );

  static Future<void> toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) => _run(
    context,
    () => ref
        .read(taskServiceProvider)
        .setFavorite(task.id, favorite: !task.isFavorite),
  );

  /// Confirms, deletes and offers Undo. [onDeleted] runs after a successful
  /// delete (e.g. to leave the detail page).
  static Future<bool> delete(
    BuildContext context,
    WidgetRef ref,
    Task task, {
    VoidCallback? onDeleted,
  }) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.taskDeleteTitle(task.title),
      message: l10n.taskDeleteMessage,
      confirmLabel: l10n.actionDelete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return false;

    final service = ref.read(taskServiceProvider);
    try {
      final deleted = await service.delete(task.id);
      if (!context.mounted) return true;
      AppToast.success(
        context,
        l10n.taskDeleted,
        actionLabel: l10n.actionUndo,
        onAction: () => service
            .restore(deleted)
            .catchError(
              (Object error) => developer.log(
                'Undo delete failed',
                name: 'tasks',
                error: error,
              ),
            ),
      );
      onDeleted?.call();
      return true;
    } on NotFoundException {
      onDeleted?.call();
      return true;
    } on AppException {
      if (context.mounted) AppToast.error(context, l10n.taskDeleteError);
      return false;
    }
  }

  static Future<void> _run(
    BuildContext context,
    Future<Object?> Function() action,
  ) async {
    try {
      await action();
    } on AppException {
      if (context.mounted) {
        AppToast.error(context, context.l10n.taskUpdateError);
      }
    }
  }
}
