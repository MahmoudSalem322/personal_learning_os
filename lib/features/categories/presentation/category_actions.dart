import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/app_toast.dart';
import '../domain/category.dart';
import 'categories_providers.dart';
import 'widgets/category_form_dialog.dart';

/// UI flows for categories: open the form, confirm deletes, show feedback.
abstract final class CategoryActions {
  /// Opens the create form (or edit form for [category]) and shows a toast
  /// on success. Returns the saved category, or `null` if cancelled.
  static Future<Category?> openForm(
    BuildContext context, {
    Category? category,
  }) async {
    final saved = await showDialog<Category>(
      context: context,
      builder: (_) => CategoryFormDialog(category: category),
    );
    if (saved != null && context.mounted) {
      AppToast.success(
        context,
        category == null
            ? context.l10n.categoryCreated
            : context.l10n.categoryUpdated,
      );
    }
    return saved;
  }

  /// Confirms, deletes and offers Undo. [onDeleted] runs after a successful
  /// delete (e.g. to leave the detail page). Returns whether it was deleted.
  static Future<bool> delete(
    BuildContext context,
    WidgetRef ref,
    Category category, {
    VoidCallback? onDeleted,
  }) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.categoryDeleteTitle(category.name),
      message: l10n.categoryDeleteMessage,
      confirmLabel: l10n.actionDelete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return false;

    final service = ref.read(categoryServiceProvider);
    try {
      final deleted = await service.delete(category.id);
      if (!context.mounted) return true;
      AppToast.success(
        context,
        l10n.categoryDeleted,
        actionLabel: l10n.actionUndo,
        onAction: () => service
            .restore(deleted)
            .catchError(
              (Object error) => developer.log(
                'Undo delete failed',
                name: 'categories',
                error: error,
              ),
            ),
      );
      onDeleted?.call();
      return true;
    } on NotFoundException {
      // Already gone (e.g. deleted in another tab); nothing to undo.
      onDeleted?.call();
      return true;
    } on AppException {
      if (context.mounted) AppToast.error(context, l10n.categoryDeleteError);
      return false;
    }
  }
}
