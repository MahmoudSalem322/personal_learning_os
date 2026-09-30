import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:personal_learning_os/core/theme/app_theme.dart';
import 'package:personal_learning_os/features/notes/presentation/widgets/markdown_view.dart';
import 'package:personal_learning_os/l10n/app_localizations.dart';

Widget host(Widget child) => MaterialApp(
  theme: AppTheme.light,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  const doc = '''
# Heading

Some **bold** text and a [link](https://riverpod.dev).

- plain item
- [ ] first task
- [x] second task

1. one
2. two

> a quote

```dart
final x = 1;
```
''';

  testWidgets('renders the supported blocks', (tester) async {
    await tester.pumpWidget(host(MarkdownView(data: doc, onOpenLink: (_) {})));

    expect(find.text('Heading'), findsOneWidget);
    expect(
      find.textContaining('Some bold text', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('plain item', findRichText: true),
      findsOneWidget,
    );
    expect(find.byType(Checkbox), findsNWidgets(2));
    expect(find.text('1.'), findsOneWidget);
    expect(find.textContaining('a quote', findRichText: true), findsOneWidget);
    expect(find.text('final x = 1;'), findsOneWidget);
    expect(find.text('dart'), findsOneWidget, reason: 'code language label');
    expect(tester.takeException(), isNull);
  });

  testWidgets('checkboxes report their task index', (tester) async {
    final toggled = <int>[];
    await tester.pumpWidget(
      host(
        MarkdownView(data: doc, onOpenLink: (_) {}, onToggleTask: toggled.add),
      ),
    );

    await tester.tap(find.byType(Checkbox).at(1));
    await tester.tap(find.byType(Checkbox).at(0));
    expect(toggled, [1, 0]);

    final second = tester.widget<Checkbox>(find.byType(Checkbox).at(1));
    expect(second.value, isTrue);
  });

  testWidgets('links call onOpenLink', (tester) async {
    final opened = <String>[];
    await tester.pumpWidget(
      host(
        MarkdownView(
          data: '[docs](https://riverpod.dev)',
          onOpenLink: opened.add,
        ),
      ),
    );
    await tester.tapOnText(find.textRange.ofSubstring('docs'));
    expect(opened, ['https://riverpod.dev']);
  });
}
