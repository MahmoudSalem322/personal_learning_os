import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../resource_type_appearance.dart';
import '../resources_providers.dart';

/// Small "type icon + title" label for a linked resource. Renders nothing
/// when the resource doesn't exist. Links to it when [linked].
class ResourceChip extends ConsumerWidget {
  const ResourceChip({
    required this.resourceId,
    super.key,
    this.linked = false,
  });

  final String? resourceId;
  final bool linked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = resourceId;
    if (id == null) return const SizedBox.shrink();
    final resource = ref.watch(
      resourcesProvider.select(
        (all) => all.value?.where((r) => r.id == id).firstOrNull,
      ),
    );
    if (resource == null) return const SizedBox.shrink();
    final colors = context.colors;

    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          resource.type.icon,
          size: AppSizes.iconSm,
          color: colors.mutedText,
        ),
        Gap.xxs,
        Flexible(
          child: Text(
            resource.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.labelMedium?.copyWith(
              color: linked ? colors.text : colors.mutedText,
            ),
          ),
        ),
      ],
    );
    if (!linked) return label;
    return InkWell(
      onTap: () => context.go(AppRoutes.resource(resource.id)),
      borderRadius: AppRadius.chip,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxs,
          vertical: 2,
        ),
        child: label,
      ),
    );
  }
}
