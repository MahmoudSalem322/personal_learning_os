import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_routes.dart';
import '../notifications_providers.dart';

/// Bell button with the unread count; opens the notifications page.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final unread = ref.watch(unreadCountProvider);
    return IconButton(
      tooltip: unread == 0
          ? l10n.navNotifications
          : l10n.notificationsUnreadCount(unread),
      onPressed: () => context.go(AppRoutes.notifications),
      icon: UnreadBadge(
        count: unread,
        child: Icon(
          unread == 0
              ? Icons.notifications_none_rounded
              : Icons.notifications_rounded,
          size: AppSizes.iconMd,
        ),
      ),
    );
  }
}

/// Puts the unread [count] on [child]; nothing when zero.
class UnreadBadge extends StatelessWidget {
  const UnreadBadge({required this.count, required this.child, super.key});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Badge(
      isLabelVisible: count > 0,
      backgroundColor: colors.error,
      textColor: colors.onStatus,
      label: Text(count > 99 ? '99+' : '$count'),
      child: child,
    );
  }
}
