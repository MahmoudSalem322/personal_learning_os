import 'package:material_ui/material_ui.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Base surface for content blocks.
///
/// When [onTap] is set the card becomes interactive: it lifts on hover,
/// shows a focus ring for keyboard users and exposes button semantics.
class AppCard extends StatefulWidget {
  const AppCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hovered = false;
  bool _focused = false;

  bool get _interactive => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shadows = context.shadows;
    final lifted = _interactive && _hovered;

    final card = AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: _focused
              ? colors.primary
              : lifted
              ? colors.borderStrong
              : colors.border,
          width: _focused ? 1.5 : 1,
        ),
        boxShadow: lifted ? shadows.md : shadows.sm,
      ),
      child: Padding(padding: widget.padding, child: widget.child),
    );

    if (!_interactive) return card;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (value) => setState(() => _hovered = value),
        onFocusChange: (value) => setState(() => _focused = value),
        borderRadius: AppRadius.card,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        mouseCursor: SystemMouseCursors.click,
        child: card,
      ),
    );
  }
}
