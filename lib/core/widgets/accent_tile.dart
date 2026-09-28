import 'package:material_ui/material_ui.dart';

import '../extensions/context_extensions.dart';
import '../theme/accent_visual.dart';
import '../theme/app_motion.dart';

/// Rounded tile with an icon on a soft accent gradient. The visual identity
/// of categories and resource types.
class AccentTile extends StatelessWidget {
  const AccentTile({
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    super.key,
    this.size = 40,
  });

  final IconData icon;

  /// ARGB mid-tones; adapted to the current theme by [AccentVisual].
  final int primaryColor;
  final int secondaryColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final visual = AccentVisual.resolve(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      brightness: Theme.of(context).brightness,
      surface: context.colors.card,
    );
    return ExcludeSemantics(
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.standard,
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: visual.gradient,
          borderRadius: BorderRadius.circular(size * 0.28),
        ),
        child: Icon(icon, size: size * 0.5, color: visual.foreground),
      ),
    );
  }
}
