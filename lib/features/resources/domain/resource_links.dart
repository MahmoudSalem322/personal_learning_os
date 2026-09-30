import 'package:flutter/foundation.dart' show immutable;

import 'resource.dart';

/// Something that can reference a resource (notes now; tasks later).
/// Implemented by those features, so the resources domain doesn't depend
/// on them.
///
/// Deleting a resource keeps the referencing items and only removes the
/// link; Undo puts the same links back.
abstract interface class ResourceLinks {
  /// Removes the link to [resourceId] from every item; returns the ids of
  /// the items that were changed.
  Future<List<String>> detach(String resourceId);

  /// Links the given items to [resourceId] again.
  Future<void> reattach(String resourceId, List<String> itemIds);
}

/// A deleted resource plus the links removed with it, for Undo.
@immutable
class DeletedResource {
  const DeletedResource(this.resource, this.detached);

  final Resource resource;

  /// Item ids unlinked from the resource, per [ResourceLinks] source (same
  /// order as the service's links).
  final List<List<String>> detached;
}
