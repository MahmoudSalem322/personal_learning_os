import '../../../core/errors/app_exception.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/url_utils.dart';
import '../../tags/domain/tags.dart';
import 'resource.dart';
import 'resource_draft.dart';
import 'resource_links.dart';
import 'resource_repository.dart';

/// Use cases for resources: validation, ids, timestamps, progress,
/// favorites and "last opened" tracking.
class ResourceService {
  ResourceService(
    this._repository, {
    List<ResourceLinks> links = const [],
    IdGenerator? ids,
    DateTime Function()? clock,
  }) : _links = List.unmodifiable(links),
       _ids = ids ?? IdGenerator(),
       _clock = clock ?? DateTime.now;

  final ResourceRepository _repository;
  final List<ResourceLinks> _links;
  final IdGenerator _ids;
  final DateTime Function() _clock;

  /// Returns every rule [draft] breaks (after normalization).
  static Set<ResourceFieldError> validate(ResourceDraft draft) {
    final d = draft.normalized();
    final errors = <ResourceFieldError>{};
    if (d.title.isEmpty) {
      errors.add(ResourceFieldError.titleRequired);
    } else if (d.title.length > ResourceRules.titleMaxLength) {
      errors.add(ResourceFieldError.titleTooLong);
    }
    if (d.description.length > ResourceRules.descriptionMaxLength) {
      errors.add(ResourceFieldError.descriptionTooLong);
    }
    if (d.url.isNotEmpty && UrlUtils.normalize(d.url) == null) {
      errors.add(ResourceFieldError.urlInvalid);
    }
    if (d.tags.length > TagRules.maxPerItem) {
      errors.add(ResourceFieldError.tooManyTags);
    }
    return errors;
  }

  Future<Resource> create(ResourceDraft draft) async {
    final d = _validated(draft);
    final now = _clock();
    final resource = Resource(
      id: _ids.next(),
      title: d.title,
      description: d.description,
      url: d.url,
      type: d.type,
      categoryId: d.categoryId,
      tags: d.tags,
      isFavorite: d.isFavorite,
      progress: d.progress,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.save(resource);
    return resource;
  }

  Future<Resource> update(String id, ResourceDraft draft) async {
    final current = await _require(id);
    final d = _validated(draft);
    final updated = current.copyWith(
      title: d.title,
      description: d.description,
      url: d.url,
      type: d.type,
      categoryId: d.categoryId,
      tags: d.tags,
      isFavorite: d.isFavorite,
      progress: d.progress,
      updatedAt: _clock(),
    );
    if (updated.copyWith(updatedAt: current.updatedAt) == current) {
      return current;
    }
    await _repository.save(updated);
    return updated;
  }

  /// Deletes the resource. Items linked to it (notes, ...) are kept and
  /// lose the link. Returns what's needed to Undo.
  Future<DeletedResource> delete(String id) async {
    final current = await _require(id);
    final detached = [for (final links in _links) await links.detach(id)];
    await _repository.delete(id);
    return DeletedResource(current, detached);
  }

  /// Undo for [delete]: puts the resource back unchanged and re-links the
  /// items that were unlinked from it.
  Future<void> restore(DeletedResource deleted) async {
    final resource = deleted.resource;
    await _repository.save(resource);
    for (var i = 0; i < _links.length && i < deleted.detached.length; i++) {
      await _links[i].reattach(resource.id, deleted.detached[i]);
    }
  }

  Future<Resource> setProgress(String id, int progress) async {
    final current = await _require(id);
    final value = progress.clamp(0, 100);
    if (value == current.progress) return current;
    final updated = current.copyWith(progress: value, updatedAt: _clock());
    await _repository.save(updated);
    return updated;
  }

  Future<Resource> setFavorite(String id, {required bool favorite}) async {
    final current = await _require(id);
    if (current.isFavorite == favorite) return current;
    // Starring is a view preference, not an edit: updatedAt stays.
    final updated = current.copyWith(isFavorite: favorite);
    await _repository.save(updated);
    return updated;
  }

  /// Records that the user just opened the resource's link.
  Future<void> markOpened(String id) async {
    final current = await _require(id);
    await _repository.save(current.copyWith(lastOpenedAt: _clock()));
  }

  ResourceDraft _validated(ResourceDraft draft) {
    final errors = validate(draft);
    if (errors.isNotEmpty) throw ResourceValidationException(errors);
    return draft.normalized();
  }

  Future<Resource> _require(String id) async {
    final current = await _repository.getById(id);
    if (current == null) throw NotFoundException('Resource $id not found');
    return current;
  }
}
