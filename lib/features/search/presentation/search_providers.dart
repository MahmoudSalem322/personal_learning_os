import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../categories/presentation/categories_providers.dart';
import '../../notes/presentation/notes_providers.dart';
import '../../resources/presentation/resources_providers.dart';
import '../../tasks/presentation/tasks_providers.dart';
import '../domain/search_index.dart';

/// Index over all data. Only alive while the search dialog is open, so
/// edits elsewhere don't rebuild it in the background.
final searchIndexProvider = Provider.autoDispose<SearchIndex>(
  (ref) => SearchIndex(
    categories: ref.watch(categoriesProvider).value ?? const [],
    resources: ref.watch(resourcesProvider).value ?? const [],
    notes: ref.watch(notesProvider).value ?? const [],
    tasks: ref.watch(tasksProvider).value ?? const [],
  ),
);
