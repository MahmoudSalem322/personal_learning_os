import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/core/theme/app_theme.dart';
import 'package:personal_learning_os/features/tags/presentation/tag_input.dart';

/// Hosts a [TagInput] with its own state, like a form would.
class _Host extends StatefulWidget {
  const _Host({this.suggestions = const []});

  final List<String> suggestions;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  List<String> tags = const [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: TagInput(
          tags: tags,
          onChanged: (value) => setState(() => tags = value),
          label: 'Tags',
          hint: 'Add a tag',
          removeTooltip: (tag) => 'Remove $tag',
          suggestions: widget.suggestions,
        ),
      ),
    );
  }
}

List<String> tagsOf(WidgetTester tester) =>
    tester.state<_HostState>(find.byType(_Host)).tags;

void main() {
  testWidgets('Enter adds a normalized tag and clears the field', (
    tester,
  ) async {
    await tester.pumpWidget(const _Host());
    await tester.enterText(find.byType(TextField), '#Flutter');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(tagsOf(tester), ['flutter']);
    expect(find.text('#flutter'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('typing a comma or space finishes the tag', (tester) async {
    await tester.pumpWidget(const _Host());
    await tester.enterText(find.byType(TextField), 'dart,');
    await tester.pump();
    expect(tagsOf(tester), ['dart']);

    await tester.enterText(find.byType(TextField), 'ui ux ');
    await tester.pump();
    expect(tagsOf(tester), ['dart', 'ui', 'ux']);
  });

  testWidgets('remove button and suggestions', (tester) async {
    await tester.pumpWidget(const _Host(suggestions: ['flutter', 'firebase']));

    await tester.enterText(find.byType(TextField), 'fl');
    await tester.pump();
    expect(find.text('#flutter'), findsOneWidget);
    expect(find.text('#firebase'), findsNothing);

    await tester.tap(find.text('#flutter'));
    await tester.pump();
    expect(tagsOf(tester), ['flutter']);

    await tester.tap(find.byTooltip('Remove flutter'));
    await tester.pump();
    expect(tagsOf(tester), isEmpty);
  });
}
