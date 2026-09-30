import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_form_dialog.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/reminder.dart';
import '../../domain/reminder_draft.dart';
import '../../domain/reminder_service.dart';
import '../reminder_appearance.dart';
import '../reminders_providers.dart';

/// Add or edit a reminder. Pops with the saved [Reminder], or `null`.
///
/// New reminders take their [target] and [targetId] from where the form was
/// opened (a task, a resource, or the reminders list for a session).
class ReminderFormDialog extends ConsumerStatefulWidget {
  const ReminderFormDialog({
    super.key,
    this.reminder,
    this.target = ReminderTarget.session,
    this.targetId,
    this.targetTitle,
  });

  final Reminder? reminder;
  final ReminderTarget target;
  final String? targetId;

  /// Name of the linked task/resource, shown at the top.
  final String? targetTitle;

  @override
  ConsumerState<ReminderFormDialog> createState() => _ReminderFormDialogState();
}

class _ReminderFormDialogState extends ConsumerState<ReminderFormDialog> {
  late final TextEditingController _title;
  late DateTime _remindAt;
  late ReminderRepeat _repeat;
  Set<ReminderFieldError> _errors = const {};
  bool _saving = false;

  bool get _isEditing => widget.reminder != null;

  ReminderTarget get _target => widget.reminder?.target ?? widget.target;

  String? get _targetId => widget.reminder?.targetId ?? widget.targetId;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    _title = TextEditingController(text: r?.title ?? '');
    final now = DateTime.now();
    // New reminders start at the next full hour.
    _remindAt =
        r?.remindAt.toLocal() ??
        DateTime(now.year, now.month, now.day, now.hour + 1);
    _repeat = r?.repeat ?? ReminderRepeat.none;
    _title.addListener(() {
      if (_errors.contains(ReminderFieldError.titleRequired)) {
        setState(
          () =>
              _errors = _errors.difference({ReminderFieldError.titleRequired}),
        );
      }
    });
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  /// Quick choices: in an hour, this evening (if still ahead), tomorrow
  /// morning.
  List<(String, DateTime)> _presets(DateTime now) {
    final l10n = context.l10n;
    final inAnHour = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour + 1,
      now.minute,
    );
    final evening = DateTime(now.year, now.month, now.day, 20);
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 9);
    return [
      (l10n.reminderPresetInAnHour, inAnHour),
      if (evening.isAfter(now)) (l10n.reminderPresetTonight, evening),
      (l10n.reminderPresetTomorrow, tomorrow),
    ];
  }

  ReminderDraft get _draft => ReminderDraft(
    target: _target,
    targetId: _targetId,
    title: _title.text,
    remindAt: _remindAt,
    repeat: _repeat,
  );

  void _setTime(DateTime value) => setState(() {
    _remindAt = value;
    _errors = _errors.difference({ReminderFieldError.timeInPast});
  });

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _remindAt.isBefore(first) ? first : _remindAt,
      firstDate: _remindAt.isBefore(first) ? _remindAt : first,
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (picked == null) return;
    _setTime(
      DateTime(
        picked.year,
        picked.month,
        picked.day,
        _remindAt.hour,
        _remindAt.minute,
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_remindAt),
    );
    if (picked == null) return;
    _setTime(
      DateTime(
        _remindAt.year,
        _remindAt.month,
        _remindAt.day,
        picked.hour,
        picked.minute,
      ),
    );
  }

  Future<void> _submit() async {
    if (_saving) return;
    final errors = ReminderService.validate(_draft, DateTime.now());
    if (errors.isNotEmpty) {
      setState(() => _errors = errors);
      return;
    }
    setState(() => _saving = true);
    final service = ref.read(reminderServiceProvider);
    try {
      final saved = _isEditing
          ? await service.update(widget.reminder!.id, _draft)
          : await service.create(_draft);
      if (mounted) Navigator.of(context).pop(saved);
    } on ReminderValidationException catch (e) {
      if (mounted) setState(() => _errors = e.errors);
    } on AppException {
      if (mounted) AppToast.error(context, context.l10n.reminderSaveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final isSession = _target == ReminderTarget.session;

    String? titleError() {
      if (_errors.contains(ReminderFieldError.titleRequired)) {
        return l10n.reminderLabelRequired;
      }
      if (_errors.contains(ReminderFieldError.titleTooLong)) {
        return l10n.validationTooLong(ReminderRules.titleMaxLength);
      }
      return null;
    }

    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: colors.text,
      side: BorderSide(color: colors.border),
    );

    return AppFormDialog(
      title: _isEditing ? l10n.reminderFormEditTitle : l10n.reminderFormTitle,
      submitLabel: _isEditing ? l10n.actionSave : l10n.reminderFormCreate,
      onSubmit: _submit,
      saving: _saving,
      maxWidth: 520,
      children: [
        if (!isSession && widget.targetTitle != null) ...[
          Row(
            children: [
              Icon(
                _target.icon,
                size: AppSizes.iconMd,
                color: colors.mutedText,
              ),
              Gap.xs,
              Expanded(
                child: Text(
                  widget.targetTitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.titleSmall,
                ),
              ),
            ],
          ),
          Gap.md,
        ],
        TextField(
          controller: _title,
          autofocus: isSession && !_isEditing,
          maxLength: ReminderRules.titleMaxLength,
          decoration: InputDecoration(
            labelText: isSession ? l10n.reminderLabel : l10n.reminderNote,
            hintText: isSession
                ? l10n.reminderLabelHint
                : l10n.reminderNoteHint,
            errorText: titleError(),
            counterText: '',
          ),
        ),
        Gap.lg,
        AppFormLabel(l10n.reminderWhen),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final (label, at) in _presets(DateTime.now()))
              ActionChip(label: Text(label), onPressed: () => _setTime(at)),
          ],
        ),
        Gap.sm,
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDate,
                style: buttonStyle,
                icon: const Icon(Icons.event_outlined, size: AppSizes.iconMd),
                label: Text(context.formatDate(_remindAt)),
              ),
            ),
            Gap.xs,
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickTime,
                style: buttonStyle,
                icon: const Icon(Icons.schedule_rounded, size: AppSizes.iconMd),
                label: Text(context.formatTime(_remindAt)),
              ),
            ),
          ],
        ),
        if (_errors.contains(ReminderFieldError.timeInPast)) ...[
          Gap.xs,
          Text(
            l10n.reminderTimeInPast,
            style: context.textStyles.bodySmall?.copyWith(color: colors.error),
          ),
        ],
        Gap.lg,
        AppFormLabel(l10n.reminderRepeat),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final repeat in ReminderRepeat.values)
              ChoiceChip(
                label: Text(repeat.label(l10n)),
                selected: repeat == _repeat,
                showCheckmark: false,
                onSelected: (_) => setState(() {
                  _repeat = repeat;
                  _errors = _errors.difference({ReminderFieldError.timeInPast});
                }),
              ),
          ],
        ),
      ],
    );
  }
}
