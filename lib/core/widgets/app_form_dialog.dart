import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:material_ui/material_ui.dart';

import '../constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Shared frame for create/edit forms: title bar with close button,
/// scrollable body, and Cancel / Submit actions.
///
/// Full screen on mobile, a centered dialog elsewhere. Esc closes;
/// Ctrl/Cmd + Enter submits from any field.
class AppFormDialog extends StatelessWidget {
  const AppFormDialog({
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
    required this.children,
    super.key,
    this.saving = false,
    this.maxWidth = 520,
  });

  final String title;
  final String submitLabel;
  final VoidCallback onSubmit;
  final List<Widget> children;

  /// Disables the actions and shows a spinner on the submit button.
  final bool saving;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void close() => Navigator.of(context).pop();

    final body = CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true):
            onSubmit,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): onSubmit,
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(title, style: context.textStyles.subheading),
                  ),
                ),
                IconButton(
                  tooltip: l10n.actionClose,
                  onPressed: close,
                  icon: const Icon(Icons.close_rounded, size: AppSizes.iconMd),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: AppSpacing.xs,
              children: [
                TextButton(
                  onPressed: saving ? null : close,
                  style: TextButton.styleFrom(
                    foregroundColor: context.colors.text,
                  ),
                  child: Text(l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: saving ? null : onSubmit,
                  child: saving
                      ? const SizedBox.square(
                          dimension: AppSizes.iconSm,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(submitLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (context.screenSize.isMobile) {
      return Dialog.fullscreen(child: SafeArea(child: body));
    }
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: 800),
        child: body,
      ),
    );
  }
}

/// Small label above a group of form controls.
class AppFormLabel extends StatelessWidget {
  const AppFormLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(text, style: context.textStyles.label),
    );
  }
}
