import 'package:flutter/foundation.dart' show immutable, listEquals;

import '../../../core/utils/url_utils.dart';

/// Kind of learning resource.
enum ResourceType {
  website,
  youtube,
  course,
  book,
  pdf,
  article,
  github,
  documentation,
  other;

  static ResourceType? tryParse(Object? raw) {
    for (final type in values) {
      if (type.name == raw) return type;
    }
    return null;
  }

  /// Best guess from a link, used to pre-fill the type in the form.
  static ResourceType detect(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return ResourceType.website;
    final host = UrlUtils.displayHost(url).toLowerCase();
    final path = uri.path.toLowerCase();

    bool hostIs(String domain) => host == domain || host.endsWith('.$domain');

    if (hostIs('youtube.com') || host == 'youtu.be') {
      return ResourceType.youtube;
    }
    if (hostIs('github.com')) return ResourceType.github;
    if (path.endsWith('.pdf')) return ResourceType.pdf;
    if (const [
      'udemy.com',
      'coursera.org',
      'edx.org',
      'pluralsight.com',
      'frontendmasters.com',
      'egghead.io',
      'codecademy.com',
      'skillshare.com',
    ].any(hostIs)) {
      return ResourceType.course;
    }
    if (const [
      'medium.com',
      'dev.to',
      'hashnode.dev',
      'substack.com',
    ].any(hostIs)) {
      return ResourceType.article;
    }
    if (host.startsWith('docs.') ||
        host.startsWith('api.') ||
        host.startsWith('developer.') ||
        path.startsWith('/docs')) {
      return ResourceType.documentation;
    }
    return ResourceType.website;
  }
}

/// A learning resource: a course, video, book, article, doc page, ...
@immutable
class Resource {
  Resource({
    required this.id,
    required this.title,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.url = '',
    this.categoryId,
    List<String> tags = const [],
    this.isFavorite = false,
    int progress = 0,
    this.lastOpenedAt,
  }) : tags = List.unmodifiable(tags),
       progress = progress.clamp(0, 100);

  /// Parses a stored record. Required fields (id, title, dates) throw
  /// [FormatException]; optional ones fall back to defaults so records from
  /// older or newer versions still load.
  factory Resource.fromJson(Map<String, Object?> json) {
    String readString(String key) {
      final value = json[key];
      if (value is String) return value;
      throw FormatException('Resource.$key: expected String, got $value');
    }

    DateTime readDate(String key) {
      final parsed = DateTime.tryParse(readString(key));
      if (parsed == null) throw FormatException('Resource.$key: bad date');
      return parsed;
    }

    final rawTags = json[_Keys.tags];
    final rawProgress = json[_Keys.progress];
    final rawCategory = json[_Keys.categoryId];
    final rawOpened = json[_Keys.lastOpenedAt];

    return Resource(
      id: readString(_Keys.id),
      title: readString(_Keys.title),
      description: json[_Keys.description] is String
          ? json[_Keys.description]! as String
          : '',
      url: json[_Keys.url] is String ? json[_Keys.url]! as String : '',
      type: ResourceType.tryParse(json[_Keys.type]) ?? ResourceType.other,
      categoryId: rawCategory is String && rawCategory.isNotEmpty
          ? rawCategory
          : null,
      tags: rawTags is List ? rawTags.whereType<String>().toList() : const [],
      isFavorite: json[_Keys.isFavorite] == true,
      progress: rawProgress is num ? rawProgress.round() : 0,
      createdAt: readDate(_Keys.createdAt),
      updatedAt: readDate(_Keys.updatedAt),
      lastOpenedAt: rawOpened is String ? DateTime.tryParse(rawOpened) : null,
    );
  }

  final String id;
  final String title;
  final String description;

  /// Absolute http(s) URL, or empty (e.g. a physical book).
  final String url;
  final ResourceType type;

  /// `null` when the resource isn't in any category.
  final String? categoryId;

  /// Normalized tags without the leading `#`.
  final List<String> tags;
  final bool isFavorite;

  /// Completion from 0 to 100.
  final int progress;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastOpenedAt;

  bool get hasUrl => url.isNotEmpty;
  bool get isStarted => progress > 0;
  bool get isCompleted => progress >= 100;

  static const Object _unset = Object();

  /// Pass `categoryId: null` to remove the category; omit it to keep it.
  Resource copyWith({
    String? title,
    String? description,
    String? url,
    ResourceType? type,
    Object? categoryId = _unset,
    List<String>? tags,
    bool? isFavorite,
    int? progress,
    DateTime? updatedAt,
    DateTime? lastOpenedAt,
  }) {
    return Resource(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      type: type ?? this.type,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      progress: progress ?? this.progress,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }

  Map<String, Object?> toJson() => {
    _Keys.id: id,
    _Keys.title: title,
    _Keys.description: description,
    _Keys.url: url,
    _Keys.type: type.name,
    _Keys.categoryId: categoryId,
    _Keys.tags: tags,
    _Keys.isFavorite: isFavorite,
    _Keys.progress: progress,
    _Keys.createdAt: createdAt.toUtc().toIso8601String(),
    _Keys.updatedAt: updatedAt.toUtc().toIso8601String(),
    _Keys.lastOpenedAt: lastOpenedAt?.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      other is Resource &&
      other.id == id &&
      other.title == title &&
      other.description == description &&
      other.url == url &&
      other.type == type &&
      other.categoryId == categoryId &&
      listEquals(other.tags, tags) &&
      other.isFavorite == isFavorite &&
      other.progress == progress &&
      other.createdAt.isAtSameMomentAs(createdAt) &&
      other.updatedAt.isAtSameMomentAs(updatedAt) &&
      _sameMoment(other.lastOpenedAt, lastOpenedAt);

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    url,
    type,
    categoryId,
    Object.hashAll(tags),
    isFavorite,
    progress,
    createdAt.millisecondsSinceEpoch,
    updatedAt.millisecondsSinceEpoch,
    lastOpenedAt?.millisecondsSinceEpoch,
  );

  @override
  String toString() => 'Resource($id, $title)';

  static bool _sameMoment(DateTime? a, DateTime? b) =>
      a == null ? b == null : b != null && a.isAtSameMomentAs(b);
}

abstract final class _Keys {
  static const id = 'id';
  static const title = 'title';
  static const description = 'description';
  static const url = 'url';
  static const type = 'type';
  static const categoryId = 'categoryId';
  static const tags = 'tags';
  static const isFavorite = 'isFavorite';
  static const progress = 'progress';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
  static const lastOpenedAt = 'lastOpenedAt';
}
