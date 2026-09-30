import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/url_utils.dart';
import '../../../core/widgets/app_icon_tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../categories/presentation/widgets/category_avatar.dart';
import '../../notes/domain/markdown_text.dart';
import '../../notes/presentation/notes_providers.dart';
import '../../resources/presentation/resource_type_appearance.dart';
import '../../resources/presentation/resources_providers.dart';
import '../../tasks/presentation/task_appearance.dart';
import '../../tasks/presentation/tasks_providers.dart';
import '../domain/search_hit.dart';
import 'search_providers.dart';

/// Keyboard shortcut that opens search, as shown in the UI.
String searchShortcutLabel() => switch (defaultTargetPlatform) {
  TargetPlatform.macOS || TargetPlatform.iOS => '⌘K',
  _ => 'Ctrl K',
};

/// Opens global search. Callers only reach this from the page itself
/// (buttons, or the shortcut, which ignores Ctrl+K while a dialog is open),
/// so it never stacks.
Future<void> showGlobalSearch(BuildContext context) => showDialog<void>(
  context: context,
  builder: (_) => const GlobalSearchDialog(),
);

/// Command-palette style search over categories, resources, notes, tasks
/// and tags. ↑/↓ move the selection, Enter opens it, Esc closes.
class GlobalSearchDialog extends ConsumerStatefulWidget {
  const GlobalSearchDialog({super.key});

  @override
  ConsumerState<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends ConsumerState<GlobalSearchDialog> {
  final _query = TextEditingController();
  final _focus = FocusNode();
  final List<GlobalKey> _rowKeys = [];
  List<SearchHit> _flat = const [];
  int _selected = 0;

  @override
  void dispose() {
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _setQuery(String value) {
    _query.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    setState(() => _selected = 0);
    _focus.requestFocus();
  }

  void _move(int delta) {
    if (_flat.isEmpty) return;
    setState(() => _selected = (_selected + delta) % _flat.length);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final row = _rowKeys[_selected].currentContext;
      if (row != null && row.mounted) {
        Scrollable.ensureVisible(
          row,
          alignmentPolicy: delta > 0
              ? ScrollPositionAlignmentPolicy.keepVisibleAtEnd
              : ScrollPositionAlignmentPolicy.keepVisibleAtStart,
        );
      }
    });
  }

  void _openSelected() {
    if (_selected < _flat.length) _open(_flat[_selected]);
  }

  void _go(String location) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.go(location);
  }

  void _open(SearchHit hit) => switch (hit) {
    TagHit(:final tag) => _setQuery('#$tag'),
    CategoryHit(:final category) => _go(AppRoutes.category(category.id)),
    ResourceHit(:final resource) => _go(AppRoutes.resource(resource.id)),
    NoteHit(:final note) => _go(AppRoutes.note(note.id)),
    TaskHit(:final task) => _go(AppRoutes.task(task.id)),
  };

  /// Opens the feature's own page with the same search applied.
  void _showAll(SearchKind kind) {
    final query = _query.text.trim();
    switch (kind) {
      case SearchKind.resource:
        ref
            .read(resourceFilterProvider.notifier)
            .update((f) => f.cleared().copyWith(query: query));
        _go(AppRoutes.resources);
      case SearchKind.note:
        ref
            .read(noteFilterProvider.notifier)
            .update((f) => f.cleared().copyWith(query: query));
        _go(AppRoutes.notes);
      case SearchKind.task:
        ref
            .read(taskFilterProvider.notifier)
            .update((f) => f.cleared().copyWith(query: query));
        _go(AppRoutes.tasks);
      case SearchKind.category || SearchKind.tag:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final isMobile = context.screenSize.isMobile;
    final results = ref.watch(searchIndexProvider).search(_query.text);
    _flat = results.flat;
    if (_selected >= _flat.length) _selected = 0;
    while (_rowKeys.length < _flat.length) {
      _rowKeys.add(GlobalKey());
    }

    final field = CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => _move(1),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _move(-1),
      },
      child: TextField(
        controller: _query,
        focusNode: _focus,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onChanged: (_) => setState(() => _selected = 0),
        onSubmitted: (_) {
          _openSelected();
          _focus.requestFocus();
        },
        style: context.textStyles.title,
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          prefixIcon: const Icon(Icons.search_rounded, size: AppSizes.iconMd),
          suffixIcon: _query.text.isEmpty
              ? null
              : IconButton(
                  tooltip: l10n.actionClearSearch,
                  icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm),
                  onPressed: () => _setQuery(''),
                ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
      ),
    );

    Widget body;
    if (_query.text.trim().isEmpty) {
      body = _Message(
        icon: Icons.manage_search_rounded,
        title: l10n.searchEmptyTitle,
        message: l10n.searchEmptyMessage,
      );
    } else if (results.isEmpty) {
      body = _Message(
        icon: Icons.search_off_rounded,
        title: l10n.searchNoResultsTitle(_query.text.trim()),
        message: l10n.searchNoResultsMessage,
      );
    } else {
      var index = 0;
      body = ListView(
        padding: const EdgeInsets.all(AppSpacing.xs),
        shrinkWrap: true,
        children: [
          for (final group in results.groups) ...[
            _GroupHeader(group: group),
            for (final hit in group.hits)
              _ResultRow(
                key: _rowKeys[index],
                hit: hit,
                query: _query.text.trim(),
                selected: index++ == _selected,
                onTap: () => _open(hit),
              ),
            if (group.hasMore &&
                group.kind != SearchKind.category &&
                group.kind != SearchKind.tag)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () => _showAll(group.kind),
                  child: Text(l10n.searchShowAll(group.total)),
                ),
              ),
          ],
        ],
      );
    }

    return Dialog(
      alignment: isMobile ? Alignment.topCenter : const Alignment(0, -0.6),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.xs : AppSpacing.lg,
        vertical: isMobile ? AppSpacing.xs : AppSpacing.xl,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 560),
        child: Semantics(
          label: l10n.searchTitle,
          scopesRoute: true,
          namesRoute: true,
          explicitChildNodes: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs,
                ),
                child: field,
              ),
              Divider(height: 1, color: colors.border),
              Flexible(child: body),
              if (!isMobile) ...[
                Divider(height: 1, color: colors.border),
                const _KeyboardHints(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group});

  final SearchGroup group;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = switch (group.kind) {
      SearchKind.category => l10n.navCategories,
      SearchKind.resource => l10n.navResources,
      SearchKind.note => l10n.navNotes,
      SearchKind.task => l10n.navTasks,
      SearchKind.tag => l10n.searchKindTags,
    };
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.xxs,
      ),
      child: Semantics(
        header: true,
        child: Text(
          '$label · ${group.total}',
          style: context.textStyles.overline.copyWith(
            color: context.colors.mutedText,
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.hit,
    required this.query,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final SearchHit hit;
  final String query;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = context.textStyles;
    final (leading, title, subtitle) = _describe(context, l10n);

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? colors.primarySoft : Colors.transparent,
        borderRadius: AppRadius.navItem,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.navItem,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                leading,
                Gap.sm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Highlighted(
                        text: title,
                        query: query.startsWith('#') ? '' : query,
                        style: text.bodyStrong,
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.caption.copyWith(color: colors.mutedText),
                        ),
                    ],
                  ),
                ),
                if (selected) ...[
                  Gap.xs,
                  Icon(
                    Icons.keyboard_return_rounded,
                    size: AppSizes.iconSm,
                    color: colors.mutedText,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Widget, String, String) _describe(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    const size = 32.0;
    return switch (hit) {
      CategoryHit(:final category) => (
        CategoryAvatar(
          icon: category.icon,
          primaryColor: category.primaryColor,
          secondaryColor: category.secondaryColor,
          size: size,
        ),
        category.name,
        category.description,
      ),
      ResourceHit(:final resource) => (
        ResourceTypeTile(type: resource.type, size: size),
        resource.title,
        resource.hasUrl
            ? UrlUtils.displayHost(resource.url)
            : resource.type.label(l10n),
      ),
      NoteHit(:final note) => (
        const AppIconTile(icon: Icons.sticky_note_2_outlined, size: size),
        note.title.isEmpty ? l10n.noteUntitled : note.title,
        MarkdownText.excerpt(note.content, maxLength: 120),
      ),
      TaskHit(:final task) => (
        AppIconTile(icon: task.status.icon, size: size),
        task.title,
        [
          task.status.label(l10n),
          if (task.dueDate != null) context.formatDate(task.dueDate!),
        ].join(' · '),
      ),
      TagHit(:final tag, :final count) => (
        const AppIconTile(icon: Icons.tag_rounded, size: size),
        '#$tag',
        l10n.searchTagItems(count),
      ),
    };
  }
}

/// [text] with the first match of [query] emphasized.
class _Highlighted extends StatelessWidget {
  const _Highlighted({
    required this.text,
    required this.query,
    required this.style,
  });

  final String text;
  final String query;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final lower = text.toLowerCase();
    final start = query.isEmpty || lower.length != text.length
        ? -1
        : lower.indexOf(query.toLowerCase());
    if (start < 0) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }
    final end = start + query.length;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: TextStyle(color: context.colors.primary),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconXl, color: colors.mutedText),
          Gap.sm,
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textStyles.title,
          ),
          Gap.xxs,
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.textStyles.body.copyWith(color: colors.mutedText),
          ),
        ],
      ),
    );
  }
}

class _KeyboardHints extends StatelessWidget {
  const _KeyboardHints();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.xxs,
        children: [
          _Hint(keys: '↑ ↓', label: l10n.searchHintNavigate),
          _Hint(keys: '↵', label: l10n.searchHintOpen),
          _Hint(keys: 'Esc', label: l10n.searchHintClose),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.keys, required this.label});

  final String keys;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.textStyles.caption.copyWith(color: colors.mutedText);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        KeyCap(label: keys),
        Gap.xxs,
        Text(label, style: style),
      ],
    );
  }
}

/// A keyboard key, e.g. in shortcut hints.
class KeyCap extends StatelessWidget {
  const KeyCap({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs + 2),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.chip,
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: context.textStyles.caption.copyWith(color: colors.mutedText),
      ),
    );
  }
}
