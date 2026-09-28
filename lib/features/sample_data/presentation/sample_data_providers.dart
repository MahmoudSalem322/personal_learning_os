import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../categories/presentation/categories_providers.dart';
import '../domain/sample_data_service.dart';

final sampleDataServiceProvider = Provider<SampleDataService>(
  (ref) => SampleDataService(ref.watch(categoryRepositoryProvider)),
);

/// Whether any sample record currently exists.
final hasSampleDataProvider = Provider<bool>((ref) {
  final categories = ref.watch(categoriesProvider).value ?? const [];
  return categories.any((c) => SampleDataService.isSampleId(c.id));
});
