import 'dart:developer' as developer;
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:material_ui/material_ui.dart';

import '../core/constants/app_sizes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../l10n/app_localizations.dart';

/// Catches errors nothing else handled, so one broken widget or a failed
/// background operation never takes the whole app down.
///
/// - Framework errors (build, layout, paint) and uncaught async errors are
///   logged.
/// - In release builds a widget that fails to build shows a small, calm
///   panel instead of the red error screen; the rest of the page works.
void installErrorHandlers() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    developer.log(
      details.exceptionAsString(),
      name: 'error',
      error: details.exception,
      stackTrace: details.stack,
    );
    if (!kReleaseMode) previous?.call(details);
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    developer.log(
      'Uncaught error',
      name: 'error',
      error: error,
      stackTrace: stackTrace,
    );
    return true;
  };

  if (kReleaseMode) {
    ErrorWidget.builder = (details) => const BrokenWidgetPlaceholder();
  }
}

/// Stands in for a widget that failed to build (release builds only).
class BrokenWidgetPlaceholder extends StatelessWidget {
  const BrokenWidgetPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    // It may render above the app's theme or localizations.
    final colors = Theme.of(context).extension<AppColors>();
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: AppSizes.iconMd,
            color: colors?.error,
          ),
          if (l10n != null) ...[
            Gap.xs,
            Flexible(
              child: Text(
                l10n.errorWidgetFailed,
                style: TextStyle(color: colors?.mutedText),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
