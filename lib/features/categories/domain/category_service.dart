import '../../../core/errors/app_exception.dart';
import '../../../core/utils/id_generator.dart';
import 'category.dart';
import 'category_draft.dart';
import 'category_repository.dart';

/// Use cases for categories: validation, ids, timestamps.
///
/// The presentation layer calls this service; it never writes to the
/// repository directly.
class CategoryService {
  CategoryService(
    this._repository, {
    IdGenerator? ids,
    DateTime Function()? clock,
  }) : _ids = ids ?? IdGenerator(),
       _clock = clock ?? DateTime.now;

  final CategoryRepository _repository;
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

  /// Deletes the category and returns it so the caller can offer Undo.
  Future<Category> delete(String id) async {
    final current = await _repository.getById(id);
    if (current == null) throw NotFoundException('Category $id not found');
    await _repository.delete(id);
    return current;
  }

  /// Puts back a category removed by [delete] (Undo), unchanged.
  Future<void> restore(Category category) => _repository.save(category);

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
