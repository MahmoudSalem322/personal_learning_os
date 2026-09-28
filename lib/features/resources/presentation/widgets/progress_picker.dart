import 'package:material_ui/material_ui.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Progress editor: quick steps (0/25/50/75/100) plus a fine slider.
///
/// [onChanged] fires while dragging (for live display); [onCommitted]
/// fires once per change (step tap or end of drag), which is when callers
/// should save.
class ProgressPicker extends StatefulWidget {
  const ProgressPicker({
    required this.value,
    required this.onCommitted,
    super.key,
    this.onChanged,
  });

  final int value;
  final ValueChanged<int> onCommitted;
  final ValueChanged<int>? onChanged;

  static const List<int> steps = [0, 25, 50, 75, 100];

  @override
  State<ProgressPicker> createState() => _ProgressPickerState();
}

class _ProgressPickerState extends State<ProgressPicker> {
  late double _dragValue = widget.value.toDouble();
  bool _dragging = false;

  @override
  void didUpdateWidget(ProgressPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dragging) _dragValue = widget.value.toDouble();
  }

  void _commit(int value) {
    setState(() => _dragValue = value.toDouble());
    widget.onChanged?.call(value);
    widget.onCommitted(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final current = _dragValue.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: AppSpacing.xxs,
                runSpacing: AppSpacing.xxs,
                children: [
                  for (final step in ProgressPicker.steps)
                    _StepButton(
                      label: l10n.progressPercent(step),
                      selected: current == step,
                      onTap: () => _commit(step),
                    ),
                ],
              ),
            ),
            Gap.sm,
            Text(
              l10n.progressPercent(current),
              style: context.textStyles.title.copyWith(
                color: current >= 100 ? colors.success : colors.text,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        Slider(
          value: _dragValue,
          max: 100,
          divisions: 20,
          label: l10n.progressPercent(current),
          activeColor: current >= 100 ? colors.success : colors.primary,
          inactiveColor: colors.border,
          onChangeStart: (_) => _dragging = true,
          onChanged: (value) {
            setState(() => _dragValue = value);
            widget.onChanged?.call(value.round());
          },
          onChangeEnd: (value) {
            _dragging = false;
            widget.onCommitted(value.round());
          },
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.chip,
        // No `alignment` here: an aligned Container expands to the full
        // width the Wrap offers, stacking the steps vertically.
        child: Container(
          constraints: const BoxConstraints(minWidth: 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs + 2,
          ),
          decoration: BoxDecoration(
            color: selected ? colors.primarySoft : colors.surfaceMuted,
            borderRadius: AppRadius.chip,
            border: Border.all(
              color: selected ? colors.primary : colors.border,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.textStyles.labelMedium?.copyWith(
              color: selected ? colors.primary : colors.mutedText,
            ),
          ),
        ),
      ),
    );
  }
}
