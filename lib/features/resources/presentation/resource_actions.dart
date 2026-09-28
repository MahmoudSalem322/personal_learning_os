import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/services/url_opener.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/app_toast.dart';
import '../domain/resource.dart';
import 'resources_providers.dart';
import 'widgets/resource_form_dialog.dart';

/// UI flows for resources: form, open, favorite, progress, delete + Undo.
abstract final class ResourceActions {
  /// Opens the create form (or edit form for [resource]). [categoryId]
  /// pre-selects a category for new resources. Returns the saved resource.
  static Future<Resource?> openForm(
    BuildContext context, {
    Resource? resource,
    String? categoryId,
  }) async {
    final saved = await showDialog<Resource>(
      context: context,
      builder: (_) =>
          ResourceFormDialog(resource: resource, initialCategoryId: categoryId),
    );
    if (saved != null && context.mounted) {
      AppToast.success(
        context,
        resource == null
            ? context.l10n.resourceCreated
            : context.l10n.resourceUpdated,
      );
    }
    return saved;
  }

  /// Opens the link in a new tab and records "last opened".
  ///
  /// The tab is opened synchronously, inside the click handler; anything
  /// awaited before it would make browsers treat it as a pop-up.
  static void open(BuildContext context, WidgetRef ref, Resource resource) {
    if (!resource.hasUrl) return;
    final opened = ref.read(urlOpenerProvider).openInNewTab(resource.url);
    if (!opened) {
      AppToast.error(context, context.l10n.resourceOpenBlocked);
      return;
    }
    ref
        .read(resourceServiceProvider)
        .markOpened(resource.id)
        .catchError(
          (Object error) => developer.log(
            'markOpened failed',
            name: 'resources',
            error: error,
          ),
        );
  }

  static Future<void> toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    Resource resource,
  ) => _run(
    context,
    () => ref
        .read(resourceServiceProvider)
        .setFavorite(resource.id, favorite: !resource.isFavorite),
  );

  static Future<void> setProgress(
    BuildContext context,
    WidgetRef ref,
    Resource resource,
    int progress,
  ) => _run(
    context,
    () => ref.read(resourceServiceProvider).setProgress(resource.id, progress),
  );

  /// Confirms, deletes and offers Undo. [onDeleted] runs after a successful
  /// delete (e.g. to leave the detail page).
  static Future<bool> delete(
    BuildContext context,
    WidgetRef ref,
    Resource resource, {
    VoidCallback? onDeleted,
  }) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.resourceDeleteTitle(resource.title),
      message: l10n.resourceDeleteMessage,
      confirmLabel: l10n.actionDelete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return false;

    final service = ref.read(resourceServiceProvider);
    try {
      final deleted = await service.delete(resource.id);
      if (!context.mounted) return true;
      AppToast.success(
        context,
        l10n.resourceDeleted,
        actionLabel: l10n.actionUndo,
        onAction: () => service
            .restore(deleted)
            .catchError(
              (Object error) => developer.log(
                'Undo delete failed',
                name: 'resources',
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
      if (context.mounted) AppToast.error(context, l10n.resourceDeleteError);
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
        AppToast.error(context, context.l10n.resourceUpdateError);
      }
    }
  }
}
