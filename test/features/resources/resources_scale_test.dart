import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/app/navigation/app_router.dart';
import 'package:personal_learning_os/features/resources/domain/resource.dart';
import 'package:personal_learning_os/features/resources/presentation/resources_providers.dart';
import 'package:personal_learning_os/features/resources/presentation/widgets/resource_card.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('1000 resources: only visible cards are built', (tester) async {
    final container = await tester.pumpLearningOs();
    final now = DateTime.utc(2026, 9, 28);
    await tester.io(
      () => container.read(resourceRepositoryProvider).saveAll([
        for (var i = 0; i < 1000; i++)
          Resource(
            id: 'r$i',
            title: 'Resource $i',
            type: ResourceType.values[i % ResourceType.values.length],
            tags: ['tag${i % 20}'],
            progress: i % 101,
            createdAt: now.subtract(Duration(minutes: i)),
            updatedAt: now,
          ),
      ]),
    );

    container.read(appRouterProvider).go('/resources');
    await tester.pumpAndSettle();

    expect(find.text('1000 resources'), findsOneWidget);
    final built = find.byType(ResourceCard).evaluate().length;
    expect(built, lessThan(40), reason: 'grid must be lazy, built $built');

    // Scrolling far down builds only the cards now in view.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -20000));
    await tester.pumpAndSettle();
    expect(find.byType(ResourceCard).evaluate().length, lessThan(40));

    // Filtering the whole library stays responsive.
    await tester.enterText(
      find.widgetWithText(TextField, 'Search title, link or #tag'),
      '#tag7',
    );
    await tester.pumpAndSettle();
    expect(find.text('50 resources'), findsOneWidget);
  });
}
