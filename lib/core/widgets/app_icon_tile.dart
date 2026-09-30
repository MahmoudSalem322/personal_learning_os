import 'package:material_ui/material_ui.dart';

import '../constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_radius.dart';

/// Small neutral square with an icon, used as a list row's leading visual
/// when the item has no accent colors of its own.
class AppIconTile extends StatelessWidget {
  const AppIconTile({required this.icon, super.key, this.size = 32});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.chip,
        border: Border.all(color: colors.border),
      ),
      child: Icon(icon, size: AppSizes.iconSm, color: colors.mutedText),
    );
  }
}
