import 'package:material_ui/material_ui.dart';

import '../constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';

enum ToastType { success, info, error }

/// Short, non-blocking feedback after an action ("Note saved").
///
/// Pass [actionLabel] and [onAction] for reversible operations (Undo).
abstract final class AppToast {
  static void success(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => _show(context, message, ToastType.success, actionLabel, onAction);

  /// With [replaceCurrent] false the toast waits for the current one to
  /// close instead of replacing it.
  static void info(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    bool replaceCurrent = true,
  }) => _show(
    context,
    message,
    ToastType.info,
    actionLabel,
    onAction,
    replaceCurrent: replaceCurrent,
  );

  static void error(BuildContext context, String message) =>
      _show(context, message, ToastType.error, null, null);

  static void _show(
    BuildContext context,
    String message,
    ToastType type,
    String? actionLabel,
    VoidCallback? onAction, {
    bool replaceCurrent = true,
  }) {
    final colors = context.colors;
    final icon = switch (type) {
      ToastType.success => Icons.check_circle_rounded,
      ToastType.info => Icons.info_rounded,
      ToastType.error => Icons.error_rounded,
    };
    final iconColor = switch (type) {
      ToastType.success => colors.success,
      ToastType.info => colors.info,
      ToastType.error => colors.error,
    };
    final isMobile = context.screenSize.isMobile;

    final messenger = ScaffoldMessenger.of(context);
    if (replaceCurrent) messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        width: isMobile ? null : 420,
        margin: isMobile ? const EdgeInsets.all(AppSpacing.md) : null,
        duration: Duration(seconds: type == ToastType.error ? 6 : 4),
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: AppSizes.iconMd),
            Gap.sm,
            Expanded(child: Text(message)),
          ],
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(label: actionLabel, onPressed: onAction)
            : null,
      ),
    );
  }
}
