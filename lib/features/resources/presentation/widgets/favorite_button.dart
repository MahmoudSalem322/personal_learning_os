import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_motion.dart';

/// Star toggle for favorites.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    required this.isFavorite,
    required this.onPressed,
    super.key,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Semantics(
      toggled: isFavorite,
      child: IconButton(
        tooltip: isFavorite
            ? l10n.resourceFavoriteRemove
            : l10n.resourceFavoriteAdd,
        onPressed: onPressed,
        icon: AnimatedSwitcher(
          duration: AppMotion.fast,
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Icon(
            isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
            key: ValueKey(isFavorite),
            size: AppSizes.iconMd,
            color: isFavorite ? colors.warning : colors.mutedText,
          ),
        ),
      ),
    );
  }
}
