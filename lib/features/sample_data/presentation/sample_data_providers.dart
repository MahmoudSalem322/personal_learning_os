import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../categories/presentation/categories_providers.dart';
import '../../resources/presentation/resources_providers.dart';
import '../domain/sample_data_service.dart';

final sampleDataServiceProvider = Provider<SampleDataService>(
  (ref) => SampleDataService(
    categories: ref.watch(categoryRepositoryProvider),
    resources: ref.watch(resourceRepositoryProvider),
  ),
);

/// Whether any sample record currently exists.
final hasSampleDataProvider = Provider<bool>((ref) {
  bool anySample(Iterable<String> ids) => ids.any(SampleDataService.isSampleId);
  final categories = ref.watch(categoriesProvider).value ?? const [];
  final resources = ref.watch(resourcesProvider).value ?? const [];
  return anySample(categories.map((c) => c.id)) ||
      anySample(resources.map((r) => r.id));
});
