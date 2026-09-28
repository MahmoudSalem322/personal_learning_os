import '../../../core/errors/app_exception.dart';
import '../../../core/utils/id_generator.dart';
import 'category.dart';
import 'category_draft.dart';
import 'category_links.dart';
import 'category_repository.dart';

/// Use cases for categories: validation, ids, timestamps, and deleting a
/// category without deleting what's inside it.
///
/// The presentation layer calls this service; it never writes to the
/// repository directly.
class CategoryService {
  CategoryService(
    this._repository, {
    List<CategoryLinks> links = const [],
    IdGenerator? ids,
    DateTime Function()? clock,
  }) : _links = List.unmodifiable(links),
       _ids = ids ?? IdGenerator(),
       _clock = clock ?? DateTime.now;

  final CategoryRepository _repository;
  final List<CategoryLinks> _links;
  final IdGenerator _ids;
  final DateTime Function() _clock;

  /// Returns every rule [draft] breaks. [existing] is used for the unique
  /// name check; [excludingId] skips the category being edited.
  static Set<CategoryFieldError> validate(
    CategoryDraft draft, {
    required Iterable<Category> existing,
    String? excludingId,
  }) {
    final d = draft.normalized();
    final errors = <CategoryFieldError>{};
    if (d.name.isEmpty) {
      errors.add(CategoryFieldError.nameRequired);
    } else if (d.name.length > CategoryRules.nameMaxLength) {
      errors.add(CategoryFieldError.nameTooLong);
    } else {
      final key = d.name.toLowerCase();
      final taken = existing.any(
        (c) => c.id != excludingId && c.name.toLowerCase() == key,
      );
      if (taken) errors.add(CategoryFieldError.nameTaken);
    }
    if (d.description.length > CategoryRules.descriptionMaxLength) {
      errors.add(CategoryFieldError.descriptionTooLong);
    }
    return errors;
  }

  Future<Category> create(CategoryDraft draft) async {
    final d = draft.normalized();
    await _ensureValid(d);
    final now = _clock();
    final category = Category(
      id: _ids.next(),
      name: d.name,
      description: d.description,
      icon: d.icon,
      primaryColor: d.primaryColor,
      secondaryColor: d.secondaryColor,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.save(category);
    return category;
  }

  Future<Category> update(String id, CategoryDraft draft) async {
    final current = await _repository.getById(id);
    if (current == null) throw NotFoundException('Category $id not found');
    final d = draft.normalized();
    await _ensureValid(d, excludingId: id);
    final updated = current.copyWith(
      name: d.name,
      description: d.description,
      icon: d.icon,
      primaryColor: d.primaryColor,
      secondaryColor: d.secondaryColor,
      updatedAt: _clock(),
    );
    if (updated.copyWith(updatedAt: current.updatedAt) == current) {
      return current; // Nothing changed; keep the original timestamp.
    }
    await _repository.save(updated);
    return updated;
  }

  /// Deletes the category. Items linked to it (resources, ...) are kept and
  /// become uncategorized. Returns what's needed to Undo.
  Future<DeletedCategory> delete(String id) async {
    final current = await _repository.getById(id);
    if (current == null) throw NotFoundException('Category $id not found');
    // Unlink first: if that fails, the category is still there and nothing
    // points at a missing category.
    final detached = [for (final links in _links) await links.detach(id)];
    await _repository.delete(id);
    return DeletedCategory(current, detached);
  }

  /// Undo for [delete]: puts the category back unchanged and re-links the
  /// items that were unlinked from it.
  Future<void> restore(DeletedCategory deleted) async {
    final category = deleted.category;
    await _repository.save(category);
    for (var i = 0; i < _links.length && i < deleted.detached.length; i++) {
      await _links[i].reattach(category.id, deleted.detached[i]);
    }
  }

  Future<void> _ensureValid(CategoryDraft draft, {String? excludingId}) async {
    final errors = validate(
      draft,
      existing: await _repository.getAll(),
      excludingId: excludingId,
    );
    if (errors.isNotEmpty) throw CategoryValidationException(errors);
  }
}

/// Case-insensitive match on name and description.
List<Category> filterCategories(List<Category> categories, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return categories;
  return categories
      .where(
        (c) =>
            c.name.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q),
      )
      .toList(growable: false);
}
