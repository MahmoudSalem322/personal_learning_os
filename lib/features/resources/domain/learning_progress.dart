import 'package:flutter/foundation.dart' show immutable;

import 'resource.dart';

/// Progress of a group of resources (e.g. one category).
///
/// **Rule:** [percent] is the arithmetic mean of the resources' progress,
/// rounded to the nearest whole number. Every resource weighs the same. A
/// group without resources has no progress (`null`), not 0%.
@immutable
class LearningProgress {
  const LearningProgress({
    required this.resourceCount,
    required this.completedCount,
    required this.percent,
  });

  factory LearningProgress.of(Iterable<Resource> resources) {
    var count = 0;
    var completed = 0;
    var total = 0;
    for (final r in resources) {
      count++;
      total += r.progress;
      if (r.isCompleted) completed++;
    }
    return LearningProgress(
      resourceCount: count,
      completedCount: completed,
      percent: count == 0 ? null : (total / count).round(),
    );
  }

  static const LearningProgress empty = LearningProgress(
    resourceCount: 0,
    completedCount: 0,
    percent: null,
  );

  final int resourceCount;
  final int completedCount;

  /// 0–100, or `null` when there are no resources.
  final int? percent;

  /// Groups [resources] by category id. Uncategorized ones are skipped.
  static Map<String, LearningProgress> byCategory(List<Resource> resources) {
    final groups = <String, List<Resource>>{};
    for (final r in resources) {
      final id = r.categoryId;
      if (id != null) (groups[id] ??= []).add(r);
    }
    return {
      for (final entry in groups.entries)
        entry.key: LearningProgress.of(entry.value),
    };
  }

  @override
  bool operator ==(Object other) =>
      other is LearningProgress &&
      other.resourceCount == resourceCount &&
      other.completedCount == completedCount &&
      other.percent == percent;

  @override
  int get hashCode => Object.hash(resourceCount, completedCount, percent);
}
