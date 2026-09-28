import 'package:flutter/foundation.dart' show immutable;

import 'category.dart';

/// Something that can reference a category (resources now; notes and tasks
/// later). Implemented by those features, so the categories domain doesn't
/// depend on them.
///
/// Deleting a category keeps the referencing items and only removes the
/// link; Undo puts the same links back.
abstract interface class CategoryLinks {
  /// Removes the link to [categoryId] from every item; returns the ids of
  /// the items that were changed.
  Future<List<String>> detach(String categoryId);

  /// Links the given items to [categoryId] again.
  Future<void> reattach(String categoryId, List<String> itemIds);
}

/// A deleted category plus the links removed with it, for Undo.
@immutable
class DeletedCategory {
  const DeletedCategory(this.category, this.detached);

  final Category category;

  /// Item ids unlinked from the category, per [CategoryLinks] source (same
  /// order as the service's links).
  final List<List<String>> detached;

  int get detachedCount => detached.fold(0, (sum, ids) => sum + ids.length);
}
