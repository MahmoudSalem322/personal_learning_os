import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../category_appearance.dart';

/// Grid of selectable category icons.
class CategoryIconPicker extends StatelessWidget {
  const CategoryIconPicker({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final option in CategoryIcons.all)
          _Choice(
            label: option.label(l10n),
            selected: option.key == selected,
            onTap: () => onChanged(option.key),
            borderRadius: AppRadius.button,
            selectedDecoration: BoxDecoration(
              color: colors.primarySoft,
              borderRadius: AppRadius.button,
              border: Border.all(color: colors.primary, width: 1.5),
            ),
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: AppRadius.button,
              border: Border.all(color: colors.border),
            ),
            child: (selected) => Icon(
              option.icon,
              size: AppSizes.iconMd,
              color: selected ? colors.primary : colors.mutedText,
            ),
          ),
      ],
    );
  }
}

/// Row of selectable color presets.
class CategoryColorPicker extends StatelessWidget {
  const CategoryColorPicker({
    required this.selectedPrimary,
    required this.onChanged,
    super.key,
  });

  /// ARGB of the current primary color; may match no preset.
  final int selectedPrimary;
  final ValueChanged<CategoryColorPreset> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final preset in CategoryColors.all)
          _Choice(
            label: preset.label(l10n),
            selected: preset.matches(selectedPrimary),
            onTap: () => onChanged(preset),
            borderRadius: AppRadius.full,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.transparent, width: 2),
            ),
            selectedDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors.text, width: 2),
            ),
            child: (selected) => Padding(
              padding: const EdgeInsets.all(3),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [preset.primary, preset.secondary],
                  ),
                ),
                child: SizedBox.expand(
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: AppSizes.iconSm,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A 40×40 selectable option with tooltip, focus ring and radio semantics.
class _Choice extends StatefulWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.decoration,
    required this.selectedDecoration,
    required this.borderRadius,
    required this.child,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final BoxDecoration decoration;
  final BoxDecoration selectedDecoration;
  final BorderRadius borderRadius;
  final Widget Function(bool selected) child;

  @override
  State<_Choice> createState() => _ChoiceState();
}

class _ChoiceState extends State<_Choice> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final decoration = widget.selected
        ? widget.selectedDecoration
        : widget.decoration;
    return Tooltip(
      message: widget.label,
      excludeFromSemantics: true,
      child: Semantics(
        label: widget.label,
        selected: widget.selected,
        inMutuallyExclusiveGroup: true,
        button: true,
        excludeSemantics: true,
        onTap: widget.onTap,
        child: InkWell(
          onTap: widget.onTap,
          onFocusChange: (value) => setState(() => _focused = value),
          borderRadius: widget.borderRadius,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            width: 40,
            height: 40,
            decoration: _focused
                ? decoration.copyWith(
                    border: Border.all(
                      color: context.colors.focusRing,
                      width: 2,
                    ),
                  )
                : decoration,
            alignment: Alignment.center,
            child: widget.child(widget.selected),
          ),
        ),
      ),
    );
  }
}
