import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/app_settings.dart';
import '../settings_controller.dart';
import '../settings_mappers.dart';
import 'preference_feedback.dart';

/// Language picker. Shows a full-width field in the expanded sidebar and an
/// icon button when [compact] is true.
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(
      settingsControllerProvider.select((s) => s.language),
    );
    final l10n = context.l10n;
    final colors = context.colors;
    final tooltip = '${l10n.languageLabel}: ${current.label(l10n)}';

    return MenuAnchor(
      menuChildren: [
        for (final option in AppLanguage.values)
          MenuItemButton(
            trailingIcon: option == current
                ? Icon(
                    Icons.check_rounded,
                    size: AppSizes.iconMd,
                    color: colors.primary,
                  )
                : null,
            onPressed: () => applyPreference(
              context,
              () => ref
                  .read(settingsControllerProvider.notifier)
                  .setLanguage(option),
            ),
            child: Text(option.label(l10n)),
          ),
      ],
      builder: (context, controller, _) {
        void toggle() =>
            controller.isOpen ? controller.close() : controller.open();

        if (compact) {
          return IconButton(
            tooltip: tooltip,
            icon: const Icon(Icons.translate_rounded, size: AppSizes.iconMd),
            onPressed: toggle,
          );
        }

        return Tooltip(
          message: tooltip,
          child: OutlinedButton(
            onPressed: toggle,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(36),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.button,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.translate_rounded,
                  size: AppSizes.iconSm + 2,
                  color: colors.mutedText,
                ),
                Gap.xs,
                Expanded(
                  child: Text(
                    current.label(l10n),
                    style: context.textStyles.label,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.unfold_more_rounded,
                  size: AppSizes.iconSm,
                  color: colors.mutedText,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
