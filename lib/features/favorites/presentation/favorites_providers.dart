import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notes/domain/note.dart';
import '../../notes/presentation/notes_providers.dart';
import '../../resources/domain/resource.dart';
import '../../resources/presentation/resources_providers.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/presentation/tasks_providers.dart';

/// Starred items of each kind, most recently updated first.
typedef Favorites = ({
  List<Resource> resources,
  List<Note> notes,
  List<Task> tasks,
});

/// What the favorites page shows.
enum FavoritesView { all, resources, notes, tasks }

final favoritesViewProvider =
    NotifierProvider<FavoritesViewController, FavoritesView>(
      FavoritesViewController.new,
    );

class FavoritesViewController extends Notifier<FavoritesView> {
  @override
  FavoritesView build() => FavoritesView.all;

  void select(FavoritesView view) => state = view;
}

/// Every favorite, once resources, notes and tasks have all loaded.
final favoritesProvider = Provider<AsyncValue<Favorites>>((ref) {
  final resources = ref.watch(resourcesProvider);
  final notes = ref.watch(notesProvider);
  final tasks = ref.watch(tasksProvider);
  final all = <AsyncValue<List<Object>>>[resources, notes, tasks];
  for (final value in all) {
    if (value.hasError && !value.hasValue) {
      return AsyncError(value.error!, value.stackTrace ?? StackTrace.empty);
    }
  }
  if (all.any((value) => !value.hasValue)) return const AsyncLoading();

  List<T> starred<T>(
    List<T> items,
    bool Function(T) isFavorite,
    DateTime Function(T) updatedAt,
  ) =>
      items.where(isFavorite).toList()
        ..sort((a, b) => updatedAt(b).compareTo(updatedAt(a)));

  return AsyncData((
    resources: starred(
      resources.requireValue,
      (r) => r.isFavorite,
      (r) => r.updatedAt,
    ),
    notes: starred(
      notes.requireValue,
      (n) => n.isFavorite && !n.isBlank,
      (n) => n.updatedAt,
    ),
    tasks: starred(tasks.requireValue, (t) => t.isFavorite, (t) => t.updatedAt),
  ));
});
