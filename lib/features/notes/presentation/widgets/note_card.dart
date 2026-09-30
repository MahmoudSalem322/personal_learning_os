import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../categories/presentation/widgets/category_chip.dart';
import '../../../resources/presentation/widgets/favorite_button.dart';
import '../../../resources/presentation/widgets/resource_chip.dart';
import '../../../tags/presentation/tag_chip.dart';
import '../../domain/markdown_text.dart';
import '../../domain/note.dart';
import '../note_actions.dart';
import '../notes_providers.dart';

/// Grid card for a note: title, plain-text preview, links, tags, checklist
/// progress and last update. Clicking opens the editor.
class NoteCard extends ConsumerWidget {
  const NoteCard({required this.note, super.key});

  final Note note;

  static const int _visibleTags = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = context.textStyles;
    final n = note;
    final excerpt = MarkdownText.excerpt(n.content);
    final tasks = MarkdownText.taskCounts(n.content);
    final hasLinks = n.categoryId != null || n.resourceId != null;

    return AppCard(
      onTap: () => context.go(AppRoutes.note(n.id)),
      semanticLabel: n.title.isEmpty ? l10n.noteUntitled : n.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  n.title.isEmpty ? l10n.noteUntitled : n.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.title.copyWith(
                    color: n.title.isEmpty ? colors.mutedText : null,
                    fontStyle: n.title.isEmpty ? FontStyle.italic : null,
                  ),
                ),
              ),
              FavoriteButton(
                isFavorite: n.isFavorite,
                onPressed: () => NoteActions.toggleFavorite(context, ref, n),
              ),
            ],
          ),
          Expanded(
            child: Text(
              excerpt,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: text.body.copyWith(color: colors.mutedText),
            ),
          ),
          if (hasLinks || n.tags.isNotEmpty) ...[
            Gap.xs,
            Row(
              spacing: AppSpacing.xs,
              children: [
                if (n.categoryId != null)
                  Flexible(child: CategoryChip(categoryId: n.categoryId)),
                if (n.resourceId != null)
                  Flexible(child: ResourceChip(resourceId: n.resourceId)),
                for (final tag in n.tags.take(_visibleTags))
                  Flexible(
                    child: TagChip(
                      tag: tag,
                      onTap: () {
                        ref
                            .read(noteFilterProvider.notifier)
                            .update((f) => f.copyWith(tag: tag));
                        context.go(AppRoutes.notes);
                      },
                    ),
                  ),
              ],
            ),
          ],
          Gap.xs,
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.dateUpdatedOn(context.formatDate(n.updatedAt)),
                  style: text.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (tasks.total > 0) ...[
                Icon(
                  Icons.checklist_rounded,
                  size: AppSizes.iconSm,
                  color: tasks.done == tasks.total
                      ? colors.success
                      : colors.mutedText,
                ),
                Gap.xxs,
                Text(
                  l10n.noteTasks(tasks.done, tasks.total),
                  style: text.caption,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact row for a note inside a resource or category page.
class NoteTile extends StatelessWidget {
  const NoteTile({required this.note, super.key});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = context.textStyles;
    final excerpt = MarkdownText.excerpt(note.content, maxLength: 140);
    return AppCard(
      onTap: () => context.go(AppRoutes.note(note.id)),
      semanticLabel: note.title.isEmpty ? l10n.noteUntitled : note.title,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(
            Icons.sticky_note_2_outlined,
            size: AppSizes.iconMd,
            color: colors.mutedText,
          ),
          Gap.sm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title.isEmpty ? l10n.noteUntitled : note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyStrong,
                ),
                if (excerpt.isNotEmpty)
                  Text(
                    excerpt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.caption,
                  ),
              ],
            ),
          ),
          Gap.sm,
          Text(context.formatDate(note.updatedAt), style: text.caption),
          if (note.isFavorite) ...[
            Gap.xs,
            Icon(
              Icons.star_rounded,
              size: AppSizes.iconSm,
              color: colors.warning,
            ),
          ],
        ],
      ),
    );
  }
}

/// Grid geometry shared by the notes grid and its skeleton.
abstract final class NoteGridLayout {
  static const SliverGridDelegate delegate =
      SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        mainAxisExtent: 236,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      );
}
