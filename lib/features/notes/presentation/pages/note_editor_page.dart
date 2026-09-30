import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/url_opener.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../resources/presentation/resources_providers.dart';
import '../../../resources/presentation/widgets/favorite_button.dart';
import '../../../tags/presentation/tag_input.dart';
import '../../domain/markdown_text.dart';
import '../../domain/note.dart';
import '../../domain/note_draft.dart';
import '../../domain/note_service.dart';
import '../editor/markdown_editing.dart';
import '../editor/markdown_toolbar.dart';
import '../note_actions.dart';
import '../notes_providers.dart';
import '../widgets/markdown_view.dart';
import '../widgets/note_links_bar.dart';

/// Opens the note with [noteId] in the editor.
class NoteEditorPage extends ConsumerWidget {
  const NoteEditorPage({required this.noteId, super.key});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ref
        .watch(noteByIdProvider(noteId))
        .when(
          loading: () => const _LoadingView(),
          error: (_, _) => AppStateView.error(
            context: context,
            onRetry: () => ref.invalidate(noteByIdProvider(noteId)),
          ),
          data: (note) => note == null
              ? AppStateView(
                  icon: Icons.sticky_note_2_outlined,
                  title: l10n.noteNotFoundTitle,
                  message: l10n.noteNotFoundMessage,
                  action: FilledButton.icon(
                    onPressed: () => context.go(AppRoutes.notes),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: AppSizes.iconMd,
                    ),
                    label: Text(l10n.noteBackToList),
                  ),
                )
              // Keyed by id: the editor keeps its own text state and only
              // takes the stored note as a starting point.
              : _NoteEditor(key: ValueKey(note.id), note: note),
        );
  }
}

enum _Mode { write, preview }

enum SaveStatus { idle, saving, saved, failed }

class _NoteEditor extends ConsumerStatefulWidget {
  const _NoteEditor({required this.note, super.key});

  /// Latest stored version (used for favorites; text comes from the
  /// editor's own controllers).
  final Note note;

  @override
  ConsumerState<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<_NoteEditor> {
  static const Duration _saveDelay = Duration(milliseconds: 600);

  // Read eagerly in initState: dispose() needs the service after `ref` is
  // no longer usable.
  late final NoteService _service;
  late final UrlOpener _urlOpener;
  late final String _id = widget.note.id;
  late final TextEditingController _title = TextEditingController(
    text: widget.note.title,
  );
  late final TextEditingController _content = TextEditingController(
    text: widget.note.content,
  );
  final FocusNode _contentFocus = FocusNode();
  late String? _categoryId = widget.note.categoryId;
  late String? _resourceId = widget.note.resourceId;
  late List<String> _tags = widget.note.tags;
  late _Mode _mode = widget.note.isBlank ? _Mode.write : _Mode.preview;

  final ValueNotifier<SaveStatus> _status = ValueNotifier(SaveStatus.idle);
  Timer? _debounce;
  bool _dirty = false;
  Future<void>? _inFlight;
  bool _warnedTooLong = false;

  NoteDraft get _draft => NoteDraft(
    title: _title.text,
    content: _content.text,
    categoryId: _categoryId,
    resourceId: _resourceId,
    tags: _tags,
  );

  @override
  void initState() {
    super.initState();
    _service = ref.read(noteServiceProvider);
    _urlOpener = ref.read(urlOpenerProvider);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    // Flush unsaved text, then drop the note if nothing was ever written.
    final Future<Object?> pending = _dirty
        ? _service.update(_id, _draft)
        : Future<Object?>.value();
    unawaited(
      pending.then((_) => _service.discardIfBlank(_id)).catchError((
        Object error,
      ) {
        developer.log('Final save failed', name: 'notes', error: error);
        return false;
      }),
    );
    _title.dispose();
    _content.dispose();
    _contentFocus.dispose();
    _status.dispose();
    super.dispose();
  }

  void _changed() {
    _dirty = true;
    _status.value = SaveStatus.idle;
    _debounce?.cancel();
    _debounce = Timer(_saveDelay, _save);
  }

  Future<void> _save() async {
    if (_inFlight != null) await _inFlight;
    if (!_dirty || !mounted) return;
    _dirty = false;
    _status.value = SaveStatus.saving;
    final completer = Completer<void>();
    _inFlight = completer.future;
    try {
      await _service.update(_id, _draft);
      if (mounted) _status.value = SaveStatus.saved;
    } on NoteValidationException {
      _dirty = true;
      if (mounted) {
        _status.value = SaveStatus.failed;
        if (!_warnedTooLong) {
          _warnedTooLong = true;
          AppToast.error(context, context.l10n.noteTooLong);
        }
      }
    } on AppException {
      // Keep it dirty so the next change retries.
      _dirty = true;
      if (mounted) _status.value = SaveStatus.failed;
    } finally {
      _inFlight = null;
      completer.complete();
    }
  }

  void _applyToContent(TextEditingValue Function(TextEditingValue) edit) {
    _content.value = edit(_content.value);
    _changed();
  }

  void _toggleTask(int index) {
    _content.text = MarkdownText.toggleTask(_content.text, index);
    _changed();
  }

  void _openLink(String href) {
    final url = UrlUtils.normalize(href);
    if (url == null || url.isEmpty) return;
    if (!_urlOpener.openInNewTab(url)) {
      AppToast.error(context, context.l10n.resourceOpenBlocked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = context.textStyles;
    final isMobile = context.screenSize.isMobile;
    final tagSuggestions = {
      ...ref.watch(noteTagsProvider),
      ...ref.watch(allTagsProvider),
    }.toList()..sort();

    final header = Row(
      children: [
        if (isMobile)
          IconButton(
            tooltip: l10n.noteBackToList,
            onPressed: () => context.go(AppRoutes.notes),
            icon: const Icon(Icons.arrow_back_rounded, size: AppSizes.iconMd),
            color: colors.mutedText,
          )
        else
          TextButton.icon(
            onPressed: () => context.go(AppRoutes.notes),
            icon: const Icon(Icons.arrow_back_rounded, size: AppSizes.iconSm),
            label: Text(l10n.noteBackToList),
            style: TextButton.styleFrom(
              foregroundColor: colors.mutedText,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            ),
          ),
        const Spacer(),
        _SaveStatusIndicator(status: _status),
        Gap.sm,
        SegmentedButton<_Mode>(
          showSelectedIcon: false,
          style: isMobile
              ? const ButtonStyle(visualDensity: VisualDensity.compact)
              : null,
          segments: [
            ButtonSegment(
              value: _Mode.write,
              icon: const Icon(Icons.edit_outlined, size: AppSizes.iconSm),
              label: isMobile ? null : Text(l10n.noteModeWrite),
              tooltip: l10n.noteModeWrite,
            ),
            ButtonSegment(
              value: _Mode.preview,
              icon: const Icon(
                Icons.visibility_outlined,
                size: AppSizes.iconSm,
              ),
              label: isMobile ? null : Text(l10n.noteModePreview),
              tooltip: l10n.noteModePreview,
            ),
          ],
          selected: {_mode},
          onSelectionChanged: (s) => setState(() => _mode = s.first),
        ),
        FavoriteButton(
          isFavorite: widget.note.isFavorite,
          onPressed: () =>
              NoteActions.toggleFavorite(context, ref, widget.note),
        ),
        IconButton(
          tooltip: l10n.actionDelete,
          onPressed: () => NoteActions.delete(
            context,
            ref,
            widget.note.copyWith(title: _title.text, content: _content.text),
            onDeleted: () => context.go(AppRoutes.notes),
          ),
          icon: Icon(
            Icons.delete_outline_rounded,
            size: AppSizes.iconMd,
            color: colors.error,
          ),
        ),
      ],
    );

    final body = ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      children: [
        TextField(
          controller: _title,
          autofocus: widget.note.isBlank,
          onChanged: (_) {
            _changed();
            setState(() {}); // Browser tab title.
          },
          onSubmitted: (_) {
            setState(() => _mode = _Mode.write);
            _contentFocus.requestFocus();
          },
          maxLength: NoteRules.titleMaxLength,
          style: text.headlineMedium,
          decoration: InputDecoration(
            hintText: l10n.noteUntitled,
            labelText: null,
            counterText: '',
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintStyle: text.headlineMedium?.copyWith(color: colors.mutedText),
          ),
        ),
        Gap.sm,
        NoteLinksBar(
          categoryId: _categoryId,
          resourceId: _resourceId,
          onCategoryChanged: (id) {
            setState(() => _categoryId = id);
            _changed();
          },
          onResourceChanged: (resource) {
            setState(() {
              _resourceId = resource?.id;
              // Filing a note under a resource also files it under the
              // resource's category, unless it already has one.
              if (resource != null && _categoryId == null) {
                _categoryId = resource.categoryId;
              }
            });
            _changed();
          },
        ),
        Gap.md,
        TagInput(
          tags: _tags,
          onChanged: (tags) {
            setState(() => _tags = tags);
            _changed();
          },
          label: l10n.resourceFormTags,
          hint: l10n.resourceFormTagsHint,
          removeTooltip: l10n.resourceFormRemoveTag,
          suggestions: tagSuggestions,
        ),
        Gap.md,
        const Divider(),
        Gap.md,
        if (_mode == _Mode.write)
          CallbackShortcuts(
            bindings: {
              const SingleActivator(
                LogicalKeyboardKey.keyB,
                control: true,
              ): () =>
                  _applyToContent((v) => MarkdownEditing.toggleInline(v, '**')),
              const SingleActivator(LogicalKeyboardKey.keyB, meta: true): () =>
                  _applyToContent((v) => MarkdownEditing.toggleInline(v, '**')),
              const SingleActivator(
                LogicalKeyboardKey.keyI,
                control: true,
              ): () =>
                  _applyToContent((v) => MarkdownEditing.toggleInline(v, '_')),
              const SingleActivator(LogicalKeyboardKey.keyI, meta: true): () =>
                  _applyToContent((v) => MarkdownEditing.toggleInline(v, '_')),
            },
            child: TextField(
              controller: _content,
              focusNode: _contentFocus,
              onChanged: (_) => _changed(),
              maxLines: null,
              minLines: 12,
              keyboardType: TextInputType.multiline,
              inputFormatters: [ListContinuationFormatter()],
              style: text.bodyLarge,
              decoration: InputDecoration(
                hintText: l10n.noteContentHint,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          )
        else if (_content.text.trim().isEmpty)
          Text(
            l10n.noteEmptyPreview,
            style: text.body.copyWith(color: colors.mutedText),
          )
        else
          MarkdownView(
            data: _content.text,
            onOpenLink: _openLink,
            onToggleTask: _toggleTask,
          ),
      ],
    );

    final page = Align(
      alignment: AlignmentDirectional.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Padding(
          padding: AppPage.paddingFor(context.screenSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              if (_mode == _Mode.write) ...[
                Gap.xs,
                MarkdownToolbar(
                  controller: _content,
                  focusNode: _contentFocus,
                  onEdited: _changed,
                ),
                const Divider(),
              ] else
                Gap.md,
              Gap.sm,
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );

    if (!TickerMode.valuesOf(context).enabled) return page;
    final title = _title.text.trim().isEmpty
        ? l10n.noteUntitled
        : _title.text.trim();
    return Title(
      title: '$title · ${l10n.appTitle}',
      color: colors.primary,
      child: page,
    );
  }
}

class _SaveStatusIndicator extends StatelessWidget {
  const _SaveStatusIndicator({required this.status});

  final ValueListenable<SaveStatus> status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final caption = context.textStyles.caption;
    return ValueListenableBuilder(
      valueListenable: status,
      builder: (context, value, _) {
        final (icon, label, color) = switch (value) {
          SaveStatus.idle => (null, null, colors.mutedText),
          SaveStatus.saving => (
            const SizedBox.square(
              dimension: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
            l10n.noteSaving,
            colors.mutedText,
          ),
          SaveStatus.saved => (
            Icon(
              Icons.check_rounded,
              size: AppSizes.iconSm,
              color: colors.success,
            ),
            l10n.noteSaved,
            colors.mutedText,
          ),
          SaveStatus.failed => (
            Icon(
              Icons.error_outline_rounded,
              size: AppSizes.iconSm,
              color: colors.error,
            ),
            l10n.noteSaveFailed,
            colors.error,
          ),
        };
        if (label == null) return const SizedBox.shrink();
        final showText = !context.screenSize.isMobile;
        return Semantics(
          liveRegion: true,
          label: label,
          child: Tooltip(
            message: label,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon!,
                if (showText) ...[
                  Gap.xxs,
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(
                      label,
                      style: caption.copyWith(color: color),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Padding(
          padding: AppPage.paddingFor(context.screenSize),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(width: 110, height: 14),
              Gap.xl,
              AppSkeleton(width: 320, height: 28),
              Gap.lg,
              AppSkeleton(height: 14),
              Gap.xs,
              AppSkeleton(height: 14),
              Gap.xs,
              AppSkeleton(width: 240, height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
