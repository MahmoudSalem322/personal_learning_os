import '../../../l10n/app_localizations.dart';
import '../../categories/domain/category.dart';
import '../../categories/presentation/category_appearance.dart';
import '../domain/sample_data_service.dart';

/// Builds the sample categories in the current language.
List<Category> sampleCategories(AppLocalizations l10n, DateTime now) {
  Category build(
    String slug,
    String name,
    String description,
    String icon,
    String color,
  ) {
    final preset = CategoryColors.byKey(color);
    return Category(
      id: '${SampleDataService.idPrefix}category-$slug',
      name: name,
      description: description,
      icon: icon,
      primaryColor: preset.primary.toARGB32(),
      secondaryColor: preset.secondary.toARGB32(),
      createdAt: now,
      updatedAt: now,
    );
  }

  return [
    build(
      'flutter',
      'Flutter',
      l10n.sampleFlutterDescription,
      'mobile',
      'blue',
    ),
    build('dart', 'Dart', l10n.sampleDartDescription, 'code', 'purple'),
    build('ui-ux', 'UI/UX', l10n.sampleUiUxDescription, 'design', 'orange'),
    build(
      'git',
      'Git & GitHub',
      l10n.sampleGitDescription,
      'version-control',
      'slate',
    ),
  ];
}
