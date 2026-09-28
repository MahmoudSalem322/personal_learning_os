import 'package:material_ui/material_ui.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';

/// Thin rounded progress bar for 0–100 values. Turns the success color at
/// 100%.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    required this.percent,
    super.key,
    this.height = 6,
    this.color,
  });

  final int percent;
  final double height;

  /// Fill color; defaults to primary (success when complete).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final value = percent.clamp(0, 100);
    final fill = color ?? (value >= 100 ? colors.success : colors.primary);
    return Semantics(
      value: context.l10n.progressPercent(value),
      child: ClipRRect(
        borderRadius: AppRadius.full,
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: colors.border),
              TweenAnimationBuilder<double>(
                tween: Tween(end: value / 100),
                duration: AppMotion.slow,
                curve: AppMotion.standard,
                builder: (context, factor, _) => FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: factor,
                  child: ColoredBox(color: fill),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
