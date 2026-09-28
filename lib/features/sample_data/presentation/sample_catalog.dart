import '../../../l10n/app_localizations.dart';
import '../../categories/domain/category.dart';
import '../../categories/presentation/category_appearance.dart';
import '../../resources/domain/resource.dart';
import '../domain/sample_data_service.dart';

String _categoryId(String slug) =>
    '${SampleDataService.idPrefix}category-$slug';

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
      id: _categoryId(slug),
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

/// Builds the sample resources, linked to [sampleCategories].
List<Resource> sampleResources(AppLocalizations l10n, DateTime now) {
  var order = 0;
  Resource build({
    required String slug,
    required String title,
    required String description,
    required String url,
    required ResourceType type,
    required String category,
    required List<String> tags,
    int progress = 0,
    bool favorite = false,
    Duration? openedAgo,
  }) {
    // Spread creation times so "Recently added" has a stable order.
    final created = now.subtract(Duration(minutes: order++));
    return Resource(
      id: '${SampleDataService.idPrefix}resource-$slug',
      title: title,
      description: description,
      url: url,
      type: type,
      categoryId: _categoryId(category),
      tags: tags,
      progress: progress,
      isFavorite: favorite,
      createdAt: created,
      updatedAt: created,
      lastOpenedAt: openedAgo == null ? null : now.subtract(openedAgo),
    );
  }

  return [
    build(
      slug: 'flutter-docs',
      title: 'Flutter documentation',
      description: l10n.sampleResourceFlutterDocs,
      url: 'https://docs.flutter.dev',
      type: ResourceType.documentation,
      category: 'flutter',
      tags: ['flutter', 'docs'],
      progress: 40,
      favorite: true,
      openedAgo: const Duration(hours: 3),
    ),
    build(
      slug: 'riverpod',
      title: 'Riverpod',
      description: l10n.sampleResourceRiverpod,
      url: 'https://riverpod.dev',
      type: ResourceType.documentation,
      category: 'flutter',
      tags: ['flutter', 'state-management'],
      progress: 15,
      openedAgo: const Duration(days: 1),
    ),
    build(
      slug: 'flutter-youtube',
      title: 'Flutter on YouTube',
      description: l10n.sampleResourceFlutterYoutube,
      url: 'https://www.youtube.com/@flutterdev',
      type: ResourceType.youtube,
      category: 'flutter',
      tags: ['flutter', 'video'],
    ),
    build(
      slug: 'flutter-repo',
      title: 'flutter/flutter',
      description: l10n.sampleResourceFlutterRepo,
      url: 'https://github.com/flutter/flutter',
      type: ResourceType.github,
      category: 'flutter',
      tags: ['flutter', 'open-source'],
    ),
    build(
      slug: 'dart-language',
      title: 'Dart language tour',
      description: l10n.sampleResourceDartLanguage,
      url: 'https://dart.dev/language',
      type: ResourceType.documentation,
      category: 'dart',
      tags: ['dart', 'beginner'],
      progress: 100,
      openedAgo: const Duration(days: 4),
    ),
    build(
      slug: 'effective-dart',
      title: 'Effective Dart',
      description: l10n.sampleResourceEffectiveDart,
      url: 'https://dart.dev/effective-dart',
      type: ResourceType.article,
      category: 'dart',
      tags: ['dart', 'best-practices'],
      progress: 60,
      openedAgo: const Duration(days: 2),
    ),
    build(
      slug: 'material-3',
      title: 'Material Design 3',
      description: l10n.sampleResourceMaterial,
      url: 'https://m3.material.io',
      type: ResourceType.website,
      category: 'ui-ux',
      tags: ['ui', 'design-systems'],
      progress: 25,
      favorite: true,
    ),
    build(
      slug: 'pro-git',
      title: 'Pro Git',
      description: l10n.sampleResourceProGit,
      url: 'https://git-scm.com/book/en/v2',
      type: ResourceType.book,
      category: 'git',
      tags: ['git', 'beginner'],
      progress: 50,
      openedAgo: const Duration(days: 6),
    ),
  ];
}
