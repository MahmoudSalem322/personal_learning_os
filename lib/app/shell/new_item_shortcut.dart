import 'package:flutter/services.dart'
    show HardwareKeyboard, KeyDownEvent, KeyEvent, LogicalKeyboardKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/categories/presentation/category_actions.dart';
import '../../features/notes/presentation/note_actions.dart';
import '../../features/reminders/presentation/reminder_actions.dart';
import '../../features/resources/presentation/resource_actions.dart';
import '../../features/tasks/presentation/task_actions.dart';
import '../navigation/app_destination.dart';

/// "New item" from the keyboard: Ctrl/⌘+N, or N while not typing (browsers
/// keep Ctrl+N for a new window). Creates what the current section holds:
/// a category, resource, note, task or reminder; a note elsewhere.
class NewItemShortcut extends ConsumerStatefulWidget {
  const NewItemShortcut({
    required this.destination,
    required this.child,
    super.key,
  });

  final AppDestination destination;
  final Widget child;

  @override
  ConsumerState<NewItemShortcut> createState() => _NewItemShortcutState();
}

class _NewItemShortcutState extends ConsumerState<NewItemShortcut> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.keyN) {
      return false;
    }
    final keyboard = HardwareKeyboard.instance;
    final withModifier = keyboard.isControlPressed || keyboard.isMetaPressed;
    if (keyboard.isAltPressed || keyboard.isShiftPressed) return false;
    // A plain "n" is text while typing.
    if (!withModifier && _isTyping) return false;
    if (!mounted || ModalRoute.of(context)?.isCurrent == false) return false;
    _create();
    return true;
  }

  static bool get _isTyping {
    final focused = FocusManager.instance.primaryFocus?.context;
    if (focused == null) return false;
    return focused.widget is EditableText ||
        focused.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  void _create() {
    switch (widget.destination) {
      case AppDestination.categories:
        CategoryActions.openForm(context);
      case AppDestination.resources:
        ResourceActions.openForm(context);
      case AppDestination.tasks:
        TaskActions.openForm(context);
      case AppDestination.notifications:
        ReminderActions.openForm(context);
      case AppDestination.dashboard ||
          AppDestination.notes ||
          AppDestination.favorites ||
          AppDestination.settings:
        NoteActions.createAndOpen(context, ref);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
