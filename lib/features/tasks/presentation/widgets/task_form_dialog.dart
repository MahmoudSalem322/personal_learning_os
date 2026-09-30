import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_form_dialog.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../categories/presentation/categories_providers.dart';
import '../../../categories/presentation/widgets/category_avatar.dart';
import '../../../notes/presentation/notes_providers.dart';
import '../../../resources/presentation/resources_providers.dart';
import '../../../resources/presentation/widgets/resource_chip.dart';
import '../../../resources/presentation/widgets/resource_picker_dialog.dart';
import '../../../tags/domain/tags.dart';
import '../../../tags/presentation/tag_input.dart';
import '../../domain/task.dart';
import '../../domain/task_draft.dart';
import '../../domain/task_service.dart';
import '../task_appearance.dart';
import '../tasks_providers.dart';

/// Add or edit a task. Pops with the saved [Task], or `null` when
/// cancelled.
class TaskFormDialog extends ConsumerStatefulWidget {
  const TaskFormDialog({
    super.key,
    this.task,
    this.initialCategoryId,
    this.initialResourceId,
  });

  /// The task being edited; `null` to add a new one.
  final Task? task;

  /// Pre-selected category for new tasks.
  final String? initialCategoryId;

  /// Pre-selected resource for new tasks.
  final String? initialResourceId;

  @override
  ConsumerState<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends ConsumerState<TaskFormDialog> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late String? _categoryId;
  late String? _resourceId;
  late TaskPriority _priority;
  late TaskStatus _status;
  late DateTime? _dueDate;
  late List<String> _tags;
  Set<TaskFieldError> _errors = const {};
  bool _saving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _categoryId = t?.categoryId ?? widget.initialCategoryId;
    _resourceId = t?.resourceId ?? widget.initialResourceId;
    _priority = t?.priority ?? TaskPriority.medium;
    _status = t?.status ?? TaskStatus.todo;
    _dueDate = t?.dueDate;
    _tags = t?.tags ?? const [];
    _title.addListener(() => _clearErrors({TaskFieldError.titleRequired}));
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  void _clearErrors(Set<TaskFieldError> fixed) {
    if (_errors.any(fixed.contains)) {
      setState(() => _errors = _errors.difference(fixed));
    }
  }

  TaskDraft get _draft => TaskDraft(
    title: _title.text,
    description: _description.text,
    categoryId: _categoryId,
    resourceId: _resourceId,
    priority: _priority,
    status: _status,
    dueDate: _dueDate,
    tags: _tags,
  );

  Future<void> _submit() async {
    if (_saving) return;
    final errors = TaskService.validate(_draft);
    if (errors.isNotEmpty) {
      setState(() => _errors = errors);
      return;
    }
    setState(() => _saving = true);
    final service = ref.read(taskServiceProvider);
    try {
      final saved = _isEditing
          ? await service.update(widget.task!.id, _draft)
          : await service.create(_draft);
      if (mounted) Navigator.of(context).pop(saved);
    } on TaskValidationException catch (e) {
      if (mounted) setState(() => _errors = e.errors);
    } on AppException {
      if (mounted) AppToast.error(context, context.l10n.taskSaveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickResource() async {
    final pick = await showResourcePicker(context, selectedId: _resourceId);
    if (pick == null) return;
    setState(() {
      _resourceId = pick.cleared ? null : pick.resource?.id;
    });
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initial = _dueDate ?? DateTime(now.year, now.month, now.day);
    // Wide bounds that always include the current due date.
    final first = DateTime(now.year - 5);
    final last = DateTime(now.year + 10, 12, 31);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: initial.isBefore(first) ? initial : first,
      lastDate: initial.isAfter(last) ? initial : last,
    );
    if (picked == null) return;
    setState(() => _dueDate = DateTime(picked.year, picked.month, picked.day));
  }

  String? _titleError() {
    final l10n = context.l10n;
    if (_errors.contains(TaskFieldError.titleRequired)) {
      return l10n.taskTitleRequired;
    }
    if (_errors.contains(TaskFieldError.titleTooLong)) {
      return l10n.validationTooLong(TaskRules.titleMaxLength);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final categories = ref.watch(categoriesProvider).value ?? const [];
    // A pre-selected category may have been deleted meanwhile.
    final categoryValue = categories.any((c) => c.id == _categoryId)
        ? _categoryId
        : null;

    return AppFormDialog(
      title: _isEditing ? l10n.taskFormEditTitle : l10n.taskFormCreateTitle,
      submitLabel: _isEditing ? l10n.actionSave : l10n.taskFormCreate,
      onSubmit: _submit,
      saving: _saving,
      maxWidth: 560,
      children: [
        TextField(
          controller: _title,
          autofocus: !_isEditing,
          maxLength: TaskRules.titleMaxLength,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.taskFormTitle,
            hintText: l10n.taskFormTitleHint,
            errorText: _titleError(),
            counterText: '',
          ),
        ),
        Gap.md,
        TextField(
          controller: _description,
          minLines: 2,
          maxLines: 4,
          maxLength: TaskRules.descriptionMaxLength,
          decoration: InputDecoration(
            labelText: l10n.taskFormDescription,
            hintText: l10n.taskFormDescriptionHint,
            alignLabelWithHint: true,
            errorText: _errors.contains(TaskFieldError.descriptionTooLong)
                ? l10n.validationTooLong(TaskRules.descriptionMaxLength)
                : null,
          ),
        ),
        Gap.lg,
        AppFormLabel(l10n.filterPriority),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final priority in TaskPriority.values)
              ChoiceChip(
                avatar: Icon(priority.icon, size: AppSizes.iconSm),
                label: Text(priority.label(l10n)),
                selected: priority == _priority,
                showCheckmark: false,
                onSelected: (_) => setState(() => _priority = priority),
              ),
          ],
        ),
        Gap.lg,
        AppFormLabel(l10n.filterStatus),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final status in TaskStatus.values)
              ChoiceChip(
                avatar: Icon(status.icon, size: AppSizes.iconSm),
                label: Text(status.label(l10n)),
                selected: status == _status,
                showCheckmark: false,
                onSelected: (_) => setState(() => _status = status),
              ),
          ],
        ),
        Gap.lg,
        DropdownButtonFormField<String>(
          initialValue: categoryValue ?? '',
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.resourceFormCategory),
          items: [
            DropdownMenuItem(
              value: '',
              child: Text(l10n.resourceFormNoCategory),
            ),
            for (final c in categories)
              DropdownMenuItem(
                value: c.id,
                child: Row(
                  children: [
                    CategoryAvatar(
                      icon: c.icon,
                      primaryColor: c.primaryColor,
                      secondaryColor: c.secondaryColor,
                      size: 22,
                    ),
                    Gap.xs,
                    Flexible(
                      child: Text(c.name, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
          ],
          onChanged: (value) => setState(
            () => _categoryId = (value == null || value.isEmpty) ? null : value,
          ),
        ),
        Gap.md,
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickResource,
                icon: const Icon(
                  Icons.collections_bookmark_outlined,
                  size: AppSizes.iconMd,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.mutedText,
                  side: BorderSide(color: colors.border),
                ),
                label: _resourceId == null
                    ? Text(l10n.noteResource)
                    : ResourceChip(resourceId: _resourceId),
              ),
            ),
          ],
        ),
        Gap.md,
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDueDate,
                icon: const Icon(Icons.event_outlined, size: AppSizes.iconMd),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.mutedText,
                  side: BorderSide(color: colors.border),
                ),
                label: Text(
                  _dueDate == null
                      ? l10n.taskFormNoDueDate
                      : l10n.taskDueOn(context.formatDate(_dueDate!)),
                ),
              ),
            ),
            if (_dueDate != null) ...[
              Gap.xs,
              IconButton(
                tooltip: l10n.taskFormClearDueDate,
                onPressed: () => setState(() => _dueDate = null),
                icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm),
              ),
            ],
          ],
        ),
        Gap.md,
        TagInput(
          tags: _tags,
          onChanged: (tags) => setState(() {
            _tags = tags;
            _errors = _errors.difference({TaskFieldError.tooManyTags});
          }),
          label: l10n.resourceFormTags,
          hint: l10n.resourceFormTagsHint,
          removeTooltip: l10n.resourceFormRemoveTag,
          suggestions: {
            ...ref.watch(taskTagsProvider),
            ...ref.watch(allTagsProvider),
            ...ref.watch(noteTagsProvider),
          }.toList()..sort(),
          errorText: _errors.contains(TaskFieldError.tooManyTags)
              ? l10n.taskTooManyTags(TagRules.maxPerItem)
              : null,
        ),
      ],
    );
  }
}
