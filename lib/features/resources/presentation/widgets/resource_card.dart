import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../categories/presentation/widgets/category_chip.dart';
import '../../../tags/presentation/tag_chip.dart';
import '../../domain/resource.dart';
import '../resource_actions.dart';
import '../resource_type_appearance.dart';
import '../resources_providers.dart';
import 'favorite_button.dart';
import 'resource_menu_button.dart';

/// Card for a resource: type, title, source, description, category, tags,
/// progress, and quick actions (favorite, open, more). Clicking the card
/// opens the resource page.
class ResourceCard extends ConsumerWidget {
  const ResourceCard({
    required this.resource,
    super.key,
    this.showCategory = true,
  });

  final Resource resource;

  /// Hide the category label where it's implied (a category's own page).
  final bool showCategory;

  static const int _visibleTags = 2;

  void _filterByTag(BuildContext context, WidgetRef ref, String tag) {
    ref
        .read(resourceFilterProvider.notifier)
        .update((f) => f.copyWith(tag: tag));
    context.go(AppRoutes.resources);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = context.textStyles;
    final r = resource;
    final source = r.hasUrl ? UrlUtils.displayHost(r.url) : r.type.label(l10n);
    final hiddenTags = r.tags.length - _visibleTags;

    return AppCard(
      onTap: () => context.go(AppRoutes.resource(r.id)),
      semanticLabel: r.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResourceTypeTile(type: r.type, size: 36),
              Gap.sm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.title,
                      style: text.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      source,
                      style: text.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              FavoriteButton(
                isFavorite: r.isFavorite,
                onPressed: () =>
                    ResourceActions.toggleFavorite(context, ref, r),
              ),
              ResourceMenuButton(resource: r),
            ],
          ),
          Gap.xs,
          Expanded(
            child: Text(
              r.description.isEmpty
                  ? l10n.resourceNoDescription
                  : r.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.body.copyWith(
                color: colors.mutedText,
                fontStyle: r.description.isEmpty ? FontStyle.italic : null,
              ),
            ),
          ),
          if ((showCategory && r.categoryId != null) || r.tags.isNotEmpty) ...[
            Row(
              spacing: AppSpacing.xs,
              children: [
                if (showCategory && r.categoryId != null)
                  Flexible(child: CategoryChip(categoryId: r.categoryId)),
                for (final tag in r.tags.take(_visibleTags))
                  Flexible(
                    child: TagChip(
                      tag: tag,
                      onTap: () => _filterByTag(context, ref, tag),
                    ),
                  ),
                if (hiddenTags > 0)
                  Text(l10n.resourceMoreTags(hiddenTags), style: text.caption),
              ],
            ),
            Gap.sm,
          ],
          Row(
            children: [
              Expanded(child: AppProgressBar(percent: r.progress)),
              Gap.sm,
              SizedBox(
                width: 40,
                child: Text(
                  l10n.progressPercent(r.progress),
                  style: text.caption.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              if (r.hasUrl)
                TextButton.icon(
                  onPressed: () => ResourceActions.open(context, ref, r),
                  icon: const Icon(
                    Icons.open_in_new_rounded,
                    size: AppSizes.iconSm,
                  ),
                  label: Text(l10n.resourceOpen),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
