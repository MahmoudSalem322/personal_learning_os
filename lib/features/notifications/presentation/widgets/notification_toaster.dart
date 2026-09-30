import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/app_notification.dart';
import '../notification_appearance.dart';
import '../notifications_providers.dart';

/// Keeps the notification scheduler running while the app is open and
/// shows a toast when new notifications arrive (the in-app channel).
class NotificationToaster extends ConsumerStatefulWidget {
  const NotificationToaster({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<NotificationToaster> createState() =>
      _NotificationToasterState();
}

class _NotificationToasterState extends ConsumerState<NotificationToaster> {
  StreamSubscription<List<AppNotification>>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = ref
        .read(inAppNotificationChannelProvider)
        .delivered
        .listen(_show);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _show(List<AppNotification> created) {
    if (!mounted || created.isEmpty) return;
    final l10n = context.l10n;
    final router = GoRouter.of(context);
    final message = created.length == 1
        ? '${created.single.title(context)}: ${created.single.body(context)}'
        : l10n.notificationsNewCount(created.length);
    AppToast.info(
      context,
      message,
      actionLabel: l10n.notificationsView,
      onAction: () => router.go(AppRoutes.notifications),
      // Don't cut short an Undo toast the user may be about to use.
      replaceCurrent: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watching starts the scheduler (and stops it with the app).
    ref.watch(notificationSchedulerProvider);
    return widget.child;
  }
}
