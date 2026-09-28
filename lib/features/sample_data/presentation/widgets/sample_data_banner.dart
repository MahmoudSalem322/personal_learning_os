import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../sample_data_actions.dart';
import '../sample_data_providers.dart';

/// Tells the user they're looking at sample data and offers to remove it.
/// Renders nothing when no sample data exists.
class SampleDataBanner extends ConsumerWidget {
  const SampleDataBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(hasSampleDataProvider)) return const SizedBox.shrink();

    final colors = context.colors;
    final text = context.textStyles;
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.infoSoft,
        borderRadius: AppRadius.card,
      ),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.xs,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.science_outlined,
                  size: AppSizes.iconMd,
                  color: colors.info,
                ),
              ),
              Gap.sm,
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.sampleDataBannerTitle, style: text.bodyStrong),
                      Text(
                        l10n.sampleDataBannerMessage,
                        style: text.caption.copyWith(color: colors.text),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () => SampleDataActions.remove(context, ref),
            style: TextButton.styleFrom(foregroundColor: colors.info),
            child: Text(l10n.sampleDataRemove),
          ),
        ],
      ),
    );
  }
}
