import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_motion.dart';
import '../category_appearance.dart';

/// Rounded tile with the category icon on its identity gradient.
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    super.key,
    this.size = 40,
  });

  final String icon;
  final int primaryColor;
  final int secondaryColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final visual = CategoryVisual.resolve(
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
        child: Icon(
          CategoryIcons.resolve(icon),
          size: size * 0.5,
          color: visual.foreground,
        ),
      ),
    );
  }
}
