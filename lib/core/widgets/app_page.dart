import 'package:material_ui/material_ui.dart';

import '../constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/screen_size.dart';

/// Standard page layout: a header (title, subtitle, actions) above a body,
/// centered and width-constrained, with responsive padding.
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
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget body;

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

    final page = Align(
      alignment: AlignmentDirectional.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.contentMaxWidth),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(title, style: text.heading),
                      ),
                      if (subtitle != null) ...[
                        Gap.xxs,
                        Text(
                          subtitle!,
                          style: text.body.copyWith(color: colors.mutedText),
                        ),
                      ],
                    ],
                  ),
                  if (actions.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: AppSpacing.xs,
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
      title: '$title · ${context.l10n.appTitle}',
      color: colors.primary,
      child: page,
    );
  }
}
