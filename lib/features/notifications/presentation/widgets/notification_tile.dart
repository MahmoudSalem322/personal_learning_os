import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/app_notification.dart';
import '../notification_actions.dart';
import '../notification_appearance.dart';

/// One inbox row: colored type icon, title, detail, time, unread dot and a
/// menu (read/unread, remove). Tapping opens the linked item.
class NotificationTile extends ConsumerWidget {
  const NotificationTile({required this.notification, super.key});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = context.textStyles;
    final n = notification;
    final (foreground, background) = n.colorsIn(colors);
    final title = n.title(context);
    final body = n.body(context);

    return Semantics(
      label: '${n.isRead ? '' : '${l10n.notificationUnread}, '}$title',
      child: Material(
        color: n.isRead
            ? Colors.transparent
            : colors.primarySoft.withValues(alpha: 0.35),
        borderRadius: AppRadius.chip,
        child: InkWell(
          borderRadius: AppRadius.chip,
          onTap: () => NotificationActions.open(context, ref, n),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xxs,
              AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: AppRadius.chip,
                  ),
                  child: Icon(n.icon, size: AppSizes.iconMd, color: foreground),
                ),
                Gap.sm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodyStrong.copyWith(
                                fontWeight: n.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                              ),
                            ),
                          ),
                          Gap.xs,
                          Text(
                            context.formatRelative(n.createdAt),
                            style: text.caption.copyWith(
                              color: colors.mutedText,
                            ),
                          ),
                        ],
                      ),
                      Gap.xxs,
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.body.copyWith(color: colors.mutedText),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 20,
                  height: 36,
                  child: n.isRead
                      ? null
                      : Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                ),
                _Menu(notification: n),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Menu extends ConsumerWidget {
  const _Menu({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final n = notification;
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: Icon(
            n.isRead
                ? Icons.mark_email_unread_outlined
                : Icons.mark_email_read_outlined,
            size: AppSizes.iconMd,
          ),
          onPressed: () => NotificationActions.toggleRead(context, ref, n),
          child: Text(
            n.isRead ? l10n.notificationMarkUnread : l10n.notificationMarkRead,
          ),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.close_rounded, size: AppSizes.iconMd),
          onPressed: () => NotificationActions.dismiss(context, ref, n),
          child: Text(l10n.notificationRemove),
        ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: l10n.actionMore,
        icon: const Icon(Icons.more_horiz_rounded, size: AppSizes.iconMd),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
