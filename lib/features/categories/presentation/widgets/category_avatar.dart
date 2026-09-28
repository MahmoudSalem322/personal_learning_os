import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/accent_tile.dart';
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
    return AccentTile(
      icon: CategoryIcons.resolve(icon),
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      size: size,
    );
  }
}
