import 'package:material_ui/material_ui.dart';

import '../constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/screen_size.dart';

/// Standard page layout: a header (optional back link, leading visual,
/// title, subtitle, actions) above a body, centered and width-constrained,
/// with responsive padding.
///
/// Also sets the browser tab title. The [body] owns its own scrolling so
/// long lists can be virtualized.
class AppPage extends StatelessWidget {
  const AppPage({
    required this.title,
    required this.body,
    super.key,
    this.subtitle,
    this.actions = const [],
    this.leading,
    this.backLabel,
    this.documentTitle,
    this.onBack,
  }) : assert(
         (backLabel == null) == (onBack == null),
         'backLabel and onBack go together',
       );

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget body;

  /// Visual shown before the title, e.g. a category avatar.
  final Widget? leading;

  /// Adds a "← label" link above the title for detail pages.
  final String? backLabel;
  final VoidCallback? onBack;

  /// Browser tab title when it should differ from [title] (e.g. a greeting
  /// as the heading, "Dashboard" in the tab).
  final String? documentTitle;

  static EdgeInsets paddingFor(ScreenSize size) => switch (size) {
    ScreenSize.mobile => const EdgeInsets.all(AppSpacing.md),
    ScreenSize.tablet => const EdgeInsets.all(AppSpacing.lg),
    ScreenSize.desktop => const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.lg,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final padding = paddingFor(context.screenSize);

    final titleBlock = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(header: true, child: Text(title, style: text.heading)),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          Gap.xxs,
          Text(subtitle!, style: text.body.copyWith(color: colors.mutedText)),
        ],
      ],
    );

    final page = Align(
      alignment: AlignmentDirectional.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.contentMaxWidth),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (onBack != null) ...[
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: onBack,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: AppSizes.iconSm,
                    ),
                    label: Text(backLabel!),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.mutedText,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                    ),
                  ),
                ),
                Gap.xs,
              ],
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (leading == null)
                    titleBlock
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        leading!,
                        Gap.md,
                        Flexible(child: titleBlock),
                      ],
                    ),
                  if (actions.isNotEmpty)
                    // Wraps on narrow phones instead of overflowing.
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: actions,
                    ),
                ],
              ),
              Gap.lg,
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );

    // Pages kept alive in background navigation branches have tickers
    // disabled; only the visible page may set the browser tab title.
    if (!TickerMode.valuesOf(context).enabled) return page;
    return Title(
      title: '${documentTitle ?? title} · ${context.l10n.appTitle}',
      color: colors.primary,
      child: page,
    );
  }
}
