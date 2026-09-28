import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_palette.dart';
import '../../../l10n/app_localizations.dart';

/// An icon a category can use. The [key] is what gets stored.
class CategoryIconOption {
  const CategoryIconOption(this.key, this.icon, this.label);

  final String key;
  final IconData icon;
  final String Function(AppLocalizations l10n) label;
}

/// The curated icon set for categories.
abstract final class CategoryIcons {
  static const String defaultKey = 'folder';

  static final List<CategoryIconOption> all = [
    CategoryIconOption(
      'folder',
      Icons.folder_rounded,
      (l) => l.categoryIconFolder,
    ),
    CategoryIconOption('code', Icons.code_rounded, (l) => l.categoryIconCode),
    CategoryIconOption(
      'mobile',
      Icons.smartphone_rounded,
      (l) => l.categoryIconMobile,
    ),
    CategoryIconOption('web', Icons.language_rounded, (l) => l.categoryIconWeb),
    CategoryIconOption(
      'design',
      Icons.palette_rounded,
      (l) => l.categoryIconDesign,
    ),
    CategoryIconOption(
      'terminal',
      Icons.terminal_rounded,
      (l) => l.categoryIconTerminal,
    ),
    CategoryIconOption(
      'database',
      Icons.storage_rounded,
      (l) => l.categoryIconDatabase,
    ),
    CategoryIconOption(
      'cloud',
      Icons.cloud_rounded,
      (l) => l.categoryIconCloud,
    ),
    CategoryIconOption(
      'version-control',
      Icons.account_tree_rounded,
      (l) => l.categoryIconVersionControl,
    ),
    CategoryIconOption(
      'data',
      Icons.data_object_rounded,
      (l) => l.categoryIconData,
    ),
    CategoryIconOption(
      'math',
      Icons.functions_rounded,
      (l) => l.categoryIconMath,
    ),
    CategoryIconOption('ai', Icons.psychology_rounded, (l) => l.categoryIconAi),
    CategoryIconOption(
      'languages',
      Icons.translate_rounded,
      (l) => l.categoryIconLanguages,
    ),
    CategoryIconOption(
      'reading',
      Icons.menu_book_rounded,
      (l) => l.categoryIconReading,
    ),
    CategoryIconOption(
      'course',
      Icons.school_rounded,
      (l) => l.categoryIconCourse,
    ),
    CategoryIconOption(
      'science',
      Icons.science_rounded,
      (l) => l.categoryIconScience,
    ),
    CategoryIconOption(
      'ideas',
      Icons.lightbulb_rounded,
      (l) => l.categoryIconIdeas,
    ),
    CategoryIconOption(
      'projects',
      Icons.rocket_launch_rounded,
      (l) => l.categoryIconProjects,
    ),
    CategoryIconOption(
      'debugging',
      Icons.bug_report_rounded,
      (l) => l.categoryIconDebugging,
    ),
    CategoryIconOption(
      'security',
      Icons.security_rounded,
      (l) => l.categoryIconSecurity,
    ),
    CategoryIconOption(
      'analytics',
      Icons.insights_rounded,
      (l) => l.categoryIconAnalytics,
    ),
    CategoryIconOption(
      'music',
      Icons.music_note_rounded,
      (l) => l.categoryIconMusic,
    ),
  ];

  static final Map<String, IconData> _byKey = {
    for (final option in all) option.key: option.icon,
  };

  /// Unknown keys (e.g. from a newer backup) fall back to the folder icon.
  static IconData resolve(String key) => _byKey[key] ?? _byKey[defaultKey]!;
}

/// A primary/secondary color pair users can pick for a category.
class CategoryColorPreset {
  const CategoryColorPreset(this.key, this.primary, this.secondary, this.label);

  final String key;
  final Color primary;
  final Color secondary;
  final String Function(AppLocalizations l10n) label;

  bool matches(int primaryArgb) => primary.toARGB32() == primaryArgb;
}

/// The curated color set for categories.
abstract final class CategoryColors {
  static final List<CategoryColorPreset> all = [
    CategoryColorPreset(
      'blue',
      AppPalette.categoryBlue,
      AppPalette.categorySky,
      (l) => l.colorBlue,
    ),
    CategoryColorPreset(
      'indigo',
      AppPalette.categoryIndigo,
      AppPalette.categoryBlue,
      (l) => l.colorIndigo,
    ),
    CategoryColorPreset(
      'purple',
      AppPalette.categoryPurple,
      AppPalette.categoryIndigo,
      (l) => l.colorPurple,
    ),
    CategoryColorPreset(
      'pink',
      AppPalette.categoryPink,
      AppPalette.categoryRose,
      (l) => l.colorPink,
    ),
    CategoryColorPreset(
      'red',
      AppPalette.categoryRed,
      AppPalette.categoryOrange,
      (l) => l.colorRed,
    ),
    CategoryColorPreset(
      'orange',
      AppPalette.categoryOrange,
      AppPalette.categoryAmber,
      (l) => l.colorOrange,
    ),
    CategoryColorPreset(
      'amber',
      AppPalette.categoryAmber,
      AppPalette.categoryYellow,
      (l) => l.colorAmber,
    ),
    CategoryColorPreset(
      'green',
      AppPalette.categoryGreen,
      AppPalette.categoryEmerald,
      (l) => l.colorGreen,
    ),
    CategoryColorPreset(
      'teal',
      AppPalette.categoryTeal,
      AppPalette.categoryCyan,
      (l) => l.colorTeal,
    ),
    CategoryColorPreset(
      'slate',
      AppPalette.categorySlate,
      AppPalette.categoryGray,
      (l) => l.colorSlate,
    ),
  ];

  static CategoryColorPreset byKey(String key) =>
      all.firstWhere((p) => p.key == key, orElse: () => all.first);

  /// The first preset not used by [usedPrimaries], so new categories get a
  /// distinct color by default.
  static CategoryColorPreset suggest(Iterable<int> usedPrimaries) {
    final used = usedPrimaries.toSet();
    return all.firstWhere(
      (p) => !used.contains(p.primary.toARGB32()),
      orElse: () => all[used.length % all.length],
    );
  }
}
