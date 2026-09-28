import 'package:material_ui/material_ui.dart';

import '../constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Tone of an [AppStateView]; controls the icon tint.
enum AppStateTone { neutral, error }

/// Centered illustration + message + optional action.
///
/// Used for empty lists, errors, "not found" and placeholders so every
/// page communicates state the same way.
class AppStateView extends StatelessWidget {
  const AppStateView({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
    this.action,
    this.tone = AppStateTone.neutral,
  });

  /// Error state with a retry button.
  factory AppStateView.error({
    required BuildContext context,
    required VoidCallback onRetry,
    Key? key,
    String? title,
    String? message,
  }) {
    final l10n = context.l10n;
    return AppStateView(
      key: key,
      icon: Icons.error_outline_rounded,
      tone: AppStateTone.error,
      title: title ?? l10n.errorGenericTitle,
      message: message ?? l10n.errorGenericMessage,
      action: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded, size: AppSizes.iconMd),
        label: Text(l10n.actionRetry),
      ),
    );
  }

  final IconData icon;
  final String title;
  final String message;

  /// Usually a `FilledButton.icon`, e.g. "+ Add Resource".
  final Widget? action;
  final AppStateTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final (iconColor, iconBackground) = switch (tone) {
      AppStateTone.neutral => (colors.primary, colors.primarySoft),
      AppStateTone.error => (colors.error, colors.errorSoft),
    };

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.stateMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: AppSizes.iconXl, color: iconColor),
                ),
              ),
              Gap.lg,
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: text.subheading,
                  textAlign: TextAlign.center,
                ),
              ),
              Gap.xs,
              Text(
                message,
                style: text.body.copyWith(color: colors.mutedText),
                textAlign: TextAlign.center,
              ),
              if (action != null) ...[Gap.lg, action!],
            ],
          ),
        ),
      ),
    );
  }
}
