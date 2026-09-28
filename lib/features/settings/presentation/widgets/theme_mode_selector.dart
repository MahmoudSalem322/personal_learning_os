import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/app_settings.dart';
import '../settings_controller.dart';
import '../settings_mappers.dart';
import 'preference_feedback.dart';

/// Segmented Light / Dark / System switch for the expanded sidebar.
class ThemeModeSelector extends ConsumerWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(
      settingsControllerProvider.select((s) => s.themePreference),
    );
    final colors = context.colors;

    return Semantics(
      container: true,
      label: context.l10n.themeLabel,
      child: Container(
        height: 36,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: AppRadius.button,
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            for (final option in _order)
              Expanded(
                child: _Segment(
                  preference: option,
                  selected: option == current,
                  onSelected: () => applyPreference(
                    context,
                    () => ref
                        .read(settingsControllerProvider.notifier)
                        .setThemePreference(option),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static const _order = [
    ThemePreference.light,
    ThemePreference.dark,
    ThemePreference.system,
  ];
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.preference,
    required this.selected,
    required this.onSelected,
  });

  final ThemePreference preference;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = preference.label(context.l10n);
    return Tooltip(
      message: label,
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        selected: selected,
        button: true,
        label: label,
        excludeSemantics: true,
        onTap: onSelected,
        child: InkWell(
          onTap: onSelected,
          borderRadius: AppRadius.chip,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.standard,
            decoration: BoxDecoration(
              color: selected ? colors.surface : Colors.transparent,
              borderRadius: AppRadius.chip,
              boxShadow: selected ? context.shadows.sm : null,
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: Icon(
              preference.icon,
              size: AppSizes.iconSm + 2,
              color: selected ? colors.text : colors.mutedText,
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon button + menu variant for the collapsed sidebar.
class ThemeModeMenuButton extends ConsumerWidget {
  const ThemeModeMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(
      settingsControllerProvider.select((s) => s.themePreference),
    );
    final l10n = context.l10n;

    return MenuAnchor(
      menuChildren: [
        for (final option in ThemePreference.values)
          MenuItemButton(
            leadingIcon: Icon(option.icon, size: AppSizes.iconMd),
            trailingIcon: option == current
                ? Icon(
                    Icons.check_rounded,
                    size: AppSizes.iconMd,
                    color: context.colors.primary,
                  )
                : null,
            onPressed: () => applyPreference(
              context,
              () => ref
                  .read(settingsControllerProvider.notifier)
                  .setThemePreference(option),
            ),
            child: Text(option.label(l10n)),
          ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: '${l10n.themeLabel}: ${current.label(l10n)}',
        icon: Icon(current.icon, size: AppSizes.iconMd),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
