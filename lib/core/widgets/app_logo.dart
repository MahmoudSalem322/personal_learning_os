import 'package:material_ui/material_ui.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_radius.dart';

/// Brand mark: a rounded tile with the product glyph.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: AppRadius.chip,
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [colors.primary, colors.secondary],
          ),
        ),
        child: Icon(
          Icons.auto_stories_rounded,
          size: size * 0.56,
          color: colors.onPrimary,
        ),
      ),
    );
  }
}
