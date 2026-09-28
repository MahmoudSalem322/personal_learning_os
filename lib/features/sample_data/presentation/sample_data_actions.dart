import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/app_toast.dart';
import 'sample_catalog.dart';
import 'sample_data_providers.dart';

/// UI flows for loading and removing sample data, with feedback.
abstract final class SampleDataActions {
  static Future<void> load(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final now = DateTime.now();
    try {
      await ref
          .read(sampleDataServiceProvider)
          .load(
            categories: sampleCategories(l10n, now),
            resources: sampleResources(l10n, now),
          );
      if (context.mounted) AppToast.success(context, l10n.sampleDataLoaded);
    } on AppException {
      if (context.mounted) AppToast.error(context, l10n.sampleDataError);
    }
  }

  static Future<void> remove(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.sampleDataRemoveTitle,
      message: l10n.sampleDataRemoveMessage,
      confirmLabel: l10n.sampleDataRemove,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(sampleDataServiceProvider).remove();
      if (context.mounted) AppToast.success(context, l10n.sampleDataRemoved);
    } on AppException {
      if (context.mounted) AppToast.error(context, l10n.sampleDataError);
    }
  }
}
