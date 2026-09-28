import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_motion.dart';

/// Page for detail routes: a short fade with a slight upward slide, which
/// feels lighter on the web than the platform push animation.
class AppTransitionPage<T> extends CustomTransitionPage<T> {
  AppTransitionPage({required super.child, super.key})
    : super(
        transitionDuration: AppMotion.normal,
        reverseTransitionDuration: AppMotion.fast,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: AppMotion.standard,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.015),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );
}
