import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/storage/storage_providers.dart';
import '../../core/theme/app_spacing.dart';

/// Warns that data won't survive a reload when the browser blocked
/// IndexedDB and the app fell back to in-memory storage.
class StorageWarningBanner extends ConsumerStatefulWidget {
  const StorageWarningBanner({super.key});

  @override
  ConsumerState<StorageWarningBanner> createState() =>
      _StorageWarningBannerState();
}

class _StorageWarningBannerState extends ConsumerState<StorageWarningBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(storageStatusProvider);
    if (_dismissed || status == StorageStatus.persistent) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;
    return Semantics(
      liveRegion: true,
      child: Container(
        color: colors.warningSoft,
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.xs,
          AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: colors.warning,
              size: AppSizes.iconMd,
            ),
            Gap.sm,
            Expanded(
              child: Text(
                context.l10n.storageVolatileWarning,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: colors.text,
                ),
              ),
            ),
            IconButton(
              tooltip: context.l10n.actionDismiss,
              icon: const Icon(Icons.close_rounded, size: AppSizes.iconMd),
              onPressed: () => setState(() => _dismissed = true),
            ),
          ],
        ),
      ),
    );
  }
}
