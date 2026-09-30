import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/app_toast.dart';
import '../../resources/presentation/resources_providers.dart';
import '../domain/note.dart';
import '../domain/note_draft.dart';
import 'notes_providers.dart';

/// UI flows for notes: create-and-open, favorite, delete + Undo.
abstract final class NoteActions {
  /// Creates a note (optionally linked) and opens it in the editor, so a new
  /// note is one click away. When only a resource is given, the note also
  /// takes the resource's category.
  static Future<void> createAndOpen(
    BuildContext context,
    WidgetRef ref, {
    String? categoryId,
    String? resourceId,
  }) async {
    var category = categoryId;
    if (category == null && resourceId != null) {
      final resources = ref.read(resourcesProvider).value ?? const [];
      category = resources
          .where((r) => r.id == resourceId)
          .firstOrNull
          ?.categoryId;
    }
    try {
      final note = await ref
          .read(noteServiceProvider)
          .create(NoteDraft(categoryId: category, resourceId: resourceId));
      if (context.mounted) context.go(AppRoutes.note(note.id));
    } on AppException {
      if (context.mounted) {
        AppToast.error(context, context.l10n.noteCreateError);
      }
    }
  }

  static Future<void> toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    try {
      await ref
          .read(noteServiceProvider)
          .setFavorite(note.id, favorite: !note.isFavorite);
    } on AppException {
      if (context.mounted) {
        AppToast.error(context, context.l10n.noteUpdateError);
      }
    }
  }

  /// Confirms, deletes and offers Undo. Blank notes are removed without
  /// asking (there's nothing to lose). [onDeleted] runs after deleting.
  static Future<bool> delete(
    BuildContext context,
    WidgetRef ref,
    Note note, {
    VoidCallback? onDeleted,
  }) async {
    final l10n = context.l10n;
    if (!note.isBlank) {
      final confirmed = await showConfirmDialog(
        context,
        title: l10n.noteDeleteTitle(
          note.title.isEmpty ? l10n.noteUntitled : note.title,
        ),
        message: l10n.noteDeleteMessage,
        confirmLabel: l10n.actionDelete,
        destructive: true,
      );
      if (!confirmed || !context.mounted) return false;
    }

    final service = ref.read(noteServiceProvider);
    try {
      final deleted = await service.delete(note.id);
      if (!context.mounted) return true;
      if (!deleted.isBlank) {
        AppToast.success(
          context,
          l10n.noteDeleted,
          actionLabel: l10n.actionUndo,
          onAction: () => service
              .restore(deleted)
              .catchError(
                (Object error) => developer.log(
                  'Undo delete failed',
                  name: 'notes',
                  error: error,
                ),
              ),
        );
      }
      onDeleted?.call();
      return true;
    } on NotFoundException {
      onDeleted?.call();
      return true;
    } on AppException {
      if (context.mounted) AppToast.error(context, l10n.noteDeleteError);
      return false;
    }
  }
}
