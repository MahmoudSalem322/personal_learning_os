import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_icon_tile.dart';
import '../../domain/task.dart';
import '../../domain/task_filter.dart';
import '../task_appearance.dart';
import '../tasks_providers.dart';

/// Result of [showTaskPicker]: the chosen task, or `cleared` when the user
/// removed the link.
typedef TaskPick = ({Task? task, bool cleared});

/// Searchable list of tasks, open ones first. Resolves to `null` when
/// dismissed.
Future<TaskPick?> showTaskPicker(BuildContext context, {String? selectedId}) =>
    showDialog<TaskPick>(
      context: context,
      builder: (_) => _TaskPickerDialog(selectedId: selectedId),
    );

class _TaskPickerDialog extends ConsumerStatefulWidget {
  const _TaskPickerDialog({this.selectedId});

  final String? selectedId;

  @override
  ConsumerState<_TaskPickerDialog> createState() => _TaskPickerDialogState();
}

class _TaskPickerDialogState extends ConsumerState<_TaskPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final q = _query.trim().toLowerCase();
    final tasks =
        (ref.watch(tasksProvider).value ?? const <Task>[])
            .where((t) => q.isEmpty || t.title.toLowerCase().contains(q))
            .toList()
          ..sort(TaskFilter.compareOpenFirst);

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
                      l10n.noteTask,
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
                  hintText: l10n.tasksSearchHint,
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
                  title: Text(l10n.noteNoTask),
                  onTap: () =>
                      Navigator.of(context).pop((task: null, cleared: true)),
                ),
              Flexible(
                child: tasks.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          l10n.tasksNoResultsTitle,
                          textAlign: TextAlign.center,
                          style: context.textStyles.caption,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final t = tasks[index];
                          return ListTile(
                            selected: t.id == widget.selectedId,
                            selectedTileColor: colors.primarySoft,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.navItem,
                            ),
                            leading: AppIconTile(icon: t.status.icon),
                            title: Text(
                              t.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(t.status.label(l10n)),
                            onTap: () =>
                                Navigator.of(context)
                                    .pop((task: t, cleared: false)),
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
