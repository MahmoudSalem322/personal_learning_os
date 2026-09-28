import 'package:flutter/foundation.dart' show immutable;

import '../../../core/errors/app_exception.dart';
import '../../../core/utils/url_utils.dart';
import '../../tags/domain/tags.dart';
import 'resource.dart';

/// User input for creating or editing a resource, before validation.
@immutable
class ResourceDraft {
  const ResourceDraft({
    required this.title,
    required this.type,
    this.description = '',
    this.url = '',
    this.categoryId,
    this.tags = const [],
    this.progress = 0,
    this.isFavorite = false,
  });

  factory ResourceDraft.fromResource(Resource resource) => ResourceDraft(
    title: resource.title,
    description: resource.description,
    url: resource.url,
    type: resource.type,
    categoryId: resource.categoryId,
    tags: resource.tags,
    progress: resource.progress,
    isFavorite: resource.isFavorite,
  );

  final String title;
  final String description;
  final String url;
  final ResourceType type;
  final String? categoryId;
  final List<String> tags;
  final int progress;
  final bool isFavorite;

  /// Trimmed copy with a normalized URL and tags. When the title is empty
  /// and the link is valid, the site name becomes the title, so a resource
  /// can be saved from just a pasted link.
  ///
  /// An invalid URL is kept as typed so validation can report it.
  ResourceDraft normalized() {
    final normalizedUrl = UrlUtils.normalize(url);
    final cleanUrl = normalizedUrl ?? url.trim();
    var cleanTitle = title.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleanTitle.isEmpty &&
        normalizedUrl != null &&
        normalizedUrl.isNotEmpty) {
      cleanTitle = UrlUtils.displayHost(normalizedUrl);
    }
    return ResourceDraft(
      title: cleanTitle,
      description: description.trim(),
      url: cleanUrl,
      type: type,
      categoryId: categoryId,
      tags: TagRules.normalizeAll(tags),
      progress: progress.clamp(0, 100),
      isFavorite: isFavorite,
    );
  }
}

/// Limits for resource fields.
abstract final class ResourceRules {
  static const int titleMaxLength = 120;
  static const int descriptionMaxLength = 1000;
}

/// Why a [ResourceDraft] was rejected.
enum ResourceFieldError {
  titleRequired,
  titleTooLong,
  descriptionTooLong,
  urlInvalid,
  tooManyTags,
}

/// Thrown by `ResourceService` when a draft is invalid.
final class ResourceValidationException extends AppException {
  ResourceValidationException(this.errors)
    : super('Invalid resource: ${errors.map((e) => e.name).join(', ')}');

  final Set<ResourceFieldError> errors;
}
