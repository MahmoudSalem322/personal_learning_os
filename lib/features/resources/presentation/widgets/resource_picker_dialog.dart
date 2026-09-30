import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/url_utils.dart';
import '../../domain/resource.dart';
import '../resource_type_appearance.dart';
import '../resources_providers.dart';

/// Result of [showResourcePicker]: the chosen resource, or `cleared` when
/// the user removed the link.
typedef ResourcePick = ({Resource? resource, bool cleared});

/// Searchable list of resources (scales to large libraries). Resolves to
/// `null` when dismissed.
Future<ResourcePick?> showResourcePicker(
  BuildContext context, {
  String? selectedId,
}) => showDialog<ResourcePick>(
  context: context,
  builder: (_) => _ResourcePickerDialog(selectedId: selectedId),
);

class _ResourcePickerDialog extends ConsumerStatefulWidget {
  const _ResourcePickerDialog({this.selectedId});

  final String? selectedId;

  @override
  ConsumerState<_ResourcePickerDialog> createState() =>
      _ResourcePickerDialogState();
}

class _ResourcePickerDialogState extends ConsumerState<_ResourcePickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final q = _query.trim().toLowerCase();
    final resources = (ref.watch(resourcesProvider).value ?? const [])
        .where(
          (r) =>
              q.isEmpty ||
              r.title.toLowerCase().contains(q) ||
              r.url.toLowerCase().contains(q),
        )
        .toList();

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.noteResource,
                      style: context.textStyles.subheading,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.actionClose,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      size: AppSizes.iconMd,
                    ),
                  ),
                ],
              ),
              Gap.sm,
              TextField(
                autofocus: true,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: l10n.resourcesSearchHint,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: AppSizes.iconMd,
                  ),
                ),
              ),
              Gap.sm,
              if (widget.selectedId != null)
                ListTile(
                  leading: const Icon(Icons.link_off_rounded),
                  title: Text(l10n.noteNoResource),
                  onTap: () =>
                      Navigator.of(context)
                          .pop((resource: null, cleared: true)),
                ),
              Flexible(
                child: resources.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          l10n.resourcesNoResultsTitle,
                          textAlign: TextAlign.center,
                          style: context.textStyles.caption,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: resources.length,
                        itemBuilder: (context, index) {
                          final r = resources[index];
                          final selected = r.id == widget.selectedId;
                          return ListTile(
                            selected: selected,
                            selectedTileColor: colors.primarySoft,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.navItem,
                            ),
                            leading: ResourceTypeTile(type: r.type, size: 32),
                            title: Text(
                              r.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: r.hasUrl
                                ? Text(
                                    UrlUtils.displayHost(r.url),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null,
                            onTap: () =>
                                Navigator.of(context)
                                    .pop((resource: r, cleared: false)),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
