import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/accent_tile.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/resource.dart';

/// Icon, label and accent colors of each resource type.
extension ResourceTypeAppearance on ResourceType {
  IconData get icon => switch (this) {
    ResourceType.website => Icons.language_rounded,
    ResourceType.youtube => Icons.smart_display_rounded,
    ResourceType.course => Icons.school_rounded,
    ResourceType.book => Icons.menu_book_rounded,
    ResourceType.pdf => Icons.picture_as_pdf_rounded,
    ResourceType.article => Icons.article_rounded,
    ResourceType.github => Icons.code_rounded,
    ResourceType.documentation => Icons.description_rounded,
    ResourceType.other => Icons.bookmark_rounded,
  };

  String label(AppLocalizations l10n) => switch (this) {
    ResourceType.website => l10n.resourceTypeWebsite,
    ResourceType.youtube => l10n.resourceTypeYoutube,
    ResourceType.course => l10n.resourceTypeCourse,
    ResourceType.book => l10n.resourceTypeBook,
    ResourceType.pdf => l10n.resourceTypePdf,
    ResourceType.article => l10n.resourceTypeArticle,
    ResourceType.github => l10n.resourceTypeGithub,
    ResourceType.documentation => l10n.resourceTypeDocumentation,
    ResourceType.other => l10n.resourceTypeOther,
  };

  (Color, Color) get accent => switch (this) {
    ResourceType.website => (AppPalette.categorySky, AppPalette.categoryCyan),
    ResourceType.youtube => (AppPalette.categoryRed, AppPalette.categoryRose),
    ResourceType.course => (
      AppPalette.categoryPurple,
      AppPalette.categoryIndigo,
    ),
    ResourceType.book => (AppPalette.categoryAmber, AppPalette.categoryOrange),
    ResourceType.pdf => (AppPalette.categoryRose, AppPalette.categoryPink),
    ResourceType.article => (
      AppPalette.categoryTeal,
      AppPalette.categoryEmerald,
    ),
    ResourceType.github => (AppPalette.categorySlate, AppPalette.categoryGray),
    ResourceType.documentation => (
      AppPalette.categoryIndigo,
      AppPalette.categoryBlue,
    ),
    ResourceType.other => (AppPalette.categoryGray, AppPalette.categorySlate),
  };
}

/// Accent tile with the resource type icon.
class ResourceTypeTile extends StatelessWidget {
  const ResourceTypeTile({required this.type, super.key, this.size = 40});

  final ResourceType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (primary, secondary) = type.accent;
    return AccentTile(
      icon: type.icon,
      primaryColor: primary.toARGB32(),
      secondaryColor: secondary.toARGB32(),
      size: size,
    );
  }
}
