import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/app/navigation/app_router.dart';
import 'package:personal_learning_os/features/reminders/presentation/widgets/reminder_form_dialog.dart';
import 'package:personal_learning_os/features/resources/presentation/widgets/resource_form_dialog.dart';
import 'package:personal_learning_os/features/tasks/presentation/widgets/task_form_dialog.dart';

import '../helpers/test_app.dart';

Future<void> goTo(WidgetTester tester, String path) async {
  final container = await tester.pumpLearningOs();
  container.read(appRouterProvider).go(path);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('N opens the form of the current section', (tester) async {
    await goTo(tester, '/tasks');
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.pumpAndSettle();
    expect(find.byType(TaskFormDialog), findsOneWidget);
  });

  testWidgets('Ctrl+N works too', (tester) async {
    await goTo(tester, '/resources');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.byType(ResourceFormDialog), findsOneWidget);
  });

  testWidgets('on the notifications page it schedules a reminder', (
    tester,
  ) async {
    await goTo(tester, '/notifications');
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.pumpAndSettle();
    expect(find.byType(ReminderFormDialog), findsOneWidget);
  });

  testWidgets('typing "n" in a field is just text', (tester) async {
    await goTo(tester, '/tasks');
    await tester.tap(find.widgetWithText(FilledButton, 'Add task').first);
    await tester.pumpAndSettle();
    expect(find.byType(TaskFormDialog), findsOneWidget);

    // A dialog is open, and focus is in its title field: no second form.
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.pumpAndSettle();
    expect(find.byType(TaskFormDialog), findsOneWidget);
  });
}
