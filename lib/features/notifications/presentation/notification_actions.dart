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
import '../../tasks/presentation/tasks_providers.dart';
import '../domain/app_notification.dart';
import '../domain/notification_service.dart';
import 'notifications_providers.dart';

/// UI flows for the inbox: open, read state, remove (+ Undo), clear all.
abstract final class NotificationActions {
  /// Marks it read and opens its task or resource, if it still exists.
  static Future<void> open(
    BuildContext context,
    WidgetRef ref,
    AppNotification n,
  ) async {
    final router = GoRouter.of(context);
    final l10n = context.l10n;
    final location = switch (n.target) {
      NotificationTarget.task
          when (ref.read(tasksProvider).value ?? const []).any(
            (t) => t.id == n.targetId,
          ) =>
        AppRoutes.task(n.targetId!),
      NotificationTarget.resource
          when (ref.read(resourcesProvider).value ?? const []).any(
            (r) => r.id == n.targetId,
          ) =>
        AppRoutes.resource(n.targetId!),
      _ => null,
    };
    if (location != null) {
      router.go(location);
    } else if (n.target != NotificationTarget.none) {
      AppToast.info(context, l10n.notificationItemMissing);
    }
    if (!n.isRead) await _run(context, ref, (s) => s.setRead(n.id, read: true));
  }

  static Future<void> toggleRead(
    BuildContext context,
    WidgetRef ref,
    AppNotification n,
  ) => _run(context, ref, (s) => s.setRead(n.id, read: !n.isRead));

  static Future<void> markAllRead(BuildContext context, WidgetRef ref) =>
      _run(context, ref, (s) => s.markAllRead());

  /// Removes it from the inbox and offers Undo.
  static Future<void> dismiss(
    BuildContext context,
    WidgetRef ref,
    AppNotification n,
  ) async {
    final l10n = context.l10n;
    final service = ref.read(notificationServiceProvider);
    try {
      final removed = await service.dismiss(n.id);
      if (!context.mounted) return;
      AppToast.success(
        context,
        l10n.notificationRemoved,
        actionLabel: l10n.actionUndo,
        onAction: () => _restore(ref, [removed]),
      );
    } on AppException {
      if (context.mounted) AppToast.error(context, l10n.notificationsError);
    }
  }

  /// Confirms, removes every notification and offers Undo.
  static Future<void> clearAll(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.notificationsClearTitle,
      message: l10n.notificationsClearMessage,
      confirmLabel: l10n.notificationsClearAll,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final service = ref.read(notificationServiceProvider);
    try {
      final removed = await service.dismissAll();
      if (!context.mounted || removed.isEmpty) return;
      AppToast.success(
        context,
        l10n.notificationsCleared,
        actionLabel: l10n.actionUndo,
        onAction: () => _restore(ref, removed),
      );
    } on AppException {
      if (context.mounted) AppToast.error(context, l10n.notificationsError);
    }
  }

  static void _restore(WidgetRef ref, List<AppNotification> notifications) {
    ref
        .read(notificationServiceProvider)
        .restore(notifications)
        .catchError(
          (Object error) => developer.log(
            'Undo remove failed',
            name: 'notifications',
            error: error,
          ),
        );
  }

  static Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(NotificationService service) action,
  ) async {
    try {
      await action(ref.read(notificationServiceProvider));
    } on AppException {
      if (context.mounted) {
        AppToast.error(context, context.l10n.notificationsError);
      }
    }
  }
}
