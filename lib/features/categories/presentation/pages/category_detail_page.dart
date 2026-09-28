import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../domain/category.dart';
import '../categories_providers.dart';
import '../category_actions.dart';
import '../widgets/category_avatar.dart';

/// A single category: identity, metadata and (in later phases) its
/// resources, notes and tasks.
class CategoryDetailPage extends ConsumerWidget {
  const CategoryDetailPage({required this.categoryId, super.key});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    void backToList() => context.go(AppRoutes.categories);

    return ref
        .watch(categoryByIdProvider(categoryId))
        .when(
          loading: () => const _LoadingView(),
          error: (_, _) => AppStateView.error(
            context: context,
            onRetry: () => ref.invalidate(categoryByIdProvider(categoryId)),
          ),
          data: (category) => category == null
              ? AppStateView(
                  icon: Icons.category_outlined,
                  title: l10n.categoryNotFoundTitle,
                  message: l10n.categoryNotFoundMessage,
                  action: FilledButton.icon(
                    onPressed: backToList,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: AppSizes.iconMd,
                    ),
                    label: Text(l10n.categoryBackToList),
                  ),
                )
              : _CategoryView(category: category, onBack: backToList),
        );
  }
}

class _CategoryView extends ConsumerWidget {
  const _CategoryView({required this.category, required this.onBack});

  final Category category;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isMobile = context.screenSize.isMobile;

    return AppPage(
      title: category.name,
      subtitle: category.description,
      backLabel: l10n.categoryBackToList,
      onBack: onBack,
      leading: CategoryAvatar(
        icon: category.icon,
        primaryColor: category.primaryColor,
        secondaryColor: category.secondaryColor,
        size: isMobile ? 48 : 56,
      ),
      actions: [
        OutlinedButton.icon(
          onPressed: () =>
              CategoryActions.openForm(context, category: category),
          icon: const Icon(Icons.edit_outlined, size: AppSizes.iconMd),
          label: Text(l10n.actionEdit),
        ),
        IconButton(
          tooltip: l10n.actionDelete,
          onPressed: () =>
              CategoryActions.delete(context, ref, category, onDeleted: onBack),
          icon: Icon(
            Icons.delete_outline_rounded,
            size: AppSizes.iconMd,
            color: context.colors.error,
          ),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _MetaChip(
                icon: Icons.event_outlined,
                label: l10n.dateCreatedOn(
                  context.formatDate(category.createdAt),
                ),
              ),
              _MetaChip(
                icon: Icons.update_rounded,
                label: l10n.dateUpdatedOn(
                  context.formatDate(category.updatedAt),
                ),
              ),
            ],
          ),
          Gap.lg,
          Expanded(
            child: AppCard(
              child: AppStateView(
                icon: Icons.inventory_2_outlined,
                title: l10n.categoryDetailEmptyTitle,
                message: l10n.categoryDetailEmptyMessage(category.name),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.chip,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconSm, color: colors.mutedText),
          Gap.xs,
          Text(label, style: context.textStyles.caption),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPage.paddingFor(context.screenSize),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton(width: 110, height: 14),
          Gap.lg,
          Row(
            children: [
              AppSkeleton(width: 56, height: 56, borderRadius: AppRadius.card),
              Gap.md,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton(width: 200, height: 24),
                  Gap.xs,
                  AppSkeleton(width: 280, height: 14),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
