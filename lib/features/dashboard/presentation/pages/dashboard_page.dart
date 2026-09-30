import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_state_view.dart';
import '../../../categories/presentation/categories_providers.dart';
import '../../../categories/presentation/category_actions.dart';
import '../../../notes/presentation/notes_providers.dart';
import '../../../resources/presentation/resource_actions.dart';
import '../../../resources/presentation/resources_providers.dart';
import '../../../sample_data/presentation/sample_data_actions.dart';
import '../../../sample_data/presentation/widgets/sample_data_banner.dart';
import '../../../search/presentation/search_launcher.dart';
import '../../../settings/presentation/widgets/theme_mode_selector.dart';
import '../../../tasks/presentation/tasks_providers.dart';
import '../../domain/dashboard_summary.dart';
import '../dashboard_providers.dart';
import '../widgets/dashboard_sections.dart';
import '../widgets/dashboard_stats_grid.dart';
import '../widgets/quick_add_button.dart';

/// Home: greeting, totals and what to do next.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  static String greeting(BuildContext context, DateTime now) {
    final l10n = context.l10n;
    if (now.hour >= 5 && now.hour < 12) return l10n.dashboardGreetingMorning;
    if (now.hour >= 12 && now.hour < 18) {
      return l10n.dashboardGreetingAfternoon;
    }
    return l10n.dashboardGreetingEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final isMobile = context.screenSize.isMobile;
    final stats = ref.watch(dashboardStatsProvider);

    return AppPage(
      title: greeting(context, now),
      subtitle: context.formatFullDate(now),
      documentTitle: l10n.navDashboard,
      actions: [
        // Phones have search in the top bar.
        if (!isMobile)
          const SizedBox(width: 220, child: SearchLauncher(expanded: true)),
        const QuickAddButton(),
        const ThemeModeMenuButton(),
        IconButton(
          tooltip: l10n.navSettings,
          onPressed: () => context.go(AppRoutes.settings),
          icon: const Icon(Icons.settings_outlined, size: AppSizes.iconMd),
        ),
      ],
      body: stats.when(
        loading: () => const _DashboardSkeleton(),
        error: (_, _) => AppStateView.error(
          context: context,
          onRetry: () {
            ref
              ..invalidate(categoriesProvider)
              ..invalidate(resourcesProvider)
              ..invalidate(notesProvider)
              ..invalidate(tasksProvider);
          },
        ),
        data: (stats) =>
            stats.isEmpty ? const _Welcome() : _DashboardContent(stats: stats),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SampleDataBanner(),
          DashboardStatsGrid(stats: stats),
          Gap.lg,
          const ContinueLearningSection(),
          Gap.md,
          const _Pair(
            start: TodayTasksSection(),
            end: LearningProgressSection(),
          ),
          Gap.md,
          const _Pair(start: RecentResourcesSection(), end: FavoritesSection()),
        ],
      ),
    );
  }
}

/// Two sections side by side on wide screens, stacked otherwise.
class _Pair extends StatelessWidget {
  const _Pair({required this.start, required this.end});

  final Widget start;
  final Widget end;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 840) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [start, Gap.md, end],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: start),
              Gap.md,
              Expanded(child: end),
            ],
          ),
        );
      },
    );
  }
}

/// First run: nothing stored yet.
class _Welcome extends ConsumerWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AppStateView(
      icon: Icons.auto_awesome_outlined,
      title: l10n.dashboardWelcomeTitle,
      message: l10n.dashboardWelcomeMessage,
      action: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        alignment: WrapAlignment.center,
        children: [
          FilledButton.icon(
            onPressed: () => CategoryActions.openForm(context),
            icon: const Icon(Icons.add_rounded, size: AppSizes.iconMd),
            label: Text(l10n.categoriesNew),
          ),
          OutlinedButton.icon(
            onPressed: () => ResourceActions.openForm(context),
            icon: const Icon(Icons.add_rounded, size: AppSizes.iconMd),
            label: Text(l10n.resourcesNew),
          ),
          OutlinedButton.icon(
            onPressed: () => SampleDataActions.load(context, ref),
            icon: const Icon(Icons.science_outlined, size: AppSizes.iconMd),
            label: Text(l10n.sampleDataLoad),
          ),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardStatsSkeleton(),
          Gap.lg,
          AppSkeleton(height: 240, borderRadius: AppRadius.card),
        ],
      ),
    );
  }
}
