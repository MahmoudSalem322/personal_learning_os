import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/category.dart';
import '../../domain/category_draft.dart';
import '../../domain/category_service.dart';
import '../categories_providers.dart';
import '../category_appearance.dart';
import 'category_avatar.dart';
import 'category_pickers.dart';

/// Create or edit a category. Pops with the saved [Category], or `null`
/// when cancelled.
class CategoryFormDialog extends ConsumerStatefulWidget {
  const CategoryFormDialog({super.key, this.category});

  /// The category being edited; `null` to create a new one.
  final Category? category;

  @override
  ConsumerState<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late String _icon;
  late int _primary;
  late int _secondary;
  Set<CategoryFieldError> _errors = const {};
  bool _saving = false;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _name = TextEditingController(text: category?.name ?? '');
    _description = TextEditingController(text: category?.description ?? '');
    if (category != null) {
      _icon = category.icon;
      _primary = category.primaryColor;
      _secondary = category.secondaryColor;
    } else {
      final used = (ref.read(categoriesProvider).value ?? const <Category>[])
          .map((c) => c.primaryColor);
      final preset = CategoryColors.suggest(used);
      _icon = CategoryIcons.defaultKey;
      _primary = preset.primary.toARGB32();
      _secondary = preset.secondary.toARGB32();
    }
    _name.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    // Rebuild the live preview and clear stale name errors while typing.
    setState(() {
      _errors = _errors
          .where(
            (e) =>
                e != CategoryFieldError.nameRequired &&
                e != CategoryFieldError.nameTaken &&
                e != CategoryFieldError.nameTooLong,
          )
          .toSet();
    });
  }

  CategoryDraft get _draft => CategoryDraft(
    name: _name.text,
    description: _description.text,
    icon: _icon,
    primaryColor: _primary,
    secondaryColor: _secondary,
  );

  Future<void> _submit() async {
    if (_saving) return;
    final existing = ref.read(categoriesProvider).value ?? const <Category>[];
    final errors = CategoryService.validate(
      _draft,
      existing: existing,
      excludingId: widget.category?.id,
    );
    if (errors.isNotEmpty) {
      setState(() => _errors = errors);
      return;
    }

    setState(() => _saving = true);
    final service = ref.read(categoryServiceProvider);
    try {
      final saved = _isEditing
          ? await service.update(widget.category!.id, _draft)
          : await service.create(_draft);
      if (mounted) Navigator.of(context).pop(saved);
    } on CategoryValidationException catch (e) {
      if (mounted) setState(() => _errors = e.errors);
    } on AppException {
      if (mounted) AppToast.error(context, context.l10n.categorySaveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _nameError() {
    final l10n = context.l10n;
    if (_errors.contains(CategoryFieldError.nameRequired)) {
      return l10n.categoryNameRequired;
    }
    if (_errors.contains(CategoryFieldError.nameTooLong)) {
      return l10n.validationTooLong(CategoryRules.nameMaxLength);
    }
    if (_errors.contains(CategoryFieldError.nameTaken)) {
      return l10n.categoryNameTaken;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isMobile = context.screenSize.isMobile;

    final content = _FormBody(
      title: _isEditing
          ? l10n.categoryFormEditTitle
          : l10n.categoryFormCreateTitle,
      preview: _Preview(
        name: _name.text.trim(),
        icon: _icon,
        primary: _primary,
        secondary: _secondary,
      ),
      fields: [
        TextField(
          controller: _name,
          autofocus: true,
          maxLength: CategoryRules.nameMaxLength,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.categoryFormName,
            hintText: l10n.categoryFormNameHint,
            errorText: _nameError(),
            counterText: '',
          ),
        ),
        Gap.md,
        TextField(
          controller: _description,
          minLines: 2,
          maxLines: 4,
          maxLength: CategoryRules.descriptionMaxLength,
          decoration: InputDecoration(
            labelText: l10n.categoryFormDescription,
            hintText: l10n.categoryFormDescriptionHint,
            alignLabelWithHint: true,
            errorText: _errors.contains(CategoryFieldError.descriptionTooLong)
                ? l10n.validationTooLong(CategoryRules.descriptionMaxLength)
                : null,
          ),
        ),
        Gap.md,
        _SectionLabel(l10n.categoryFormIcon),
        CategoryIconPicker(
          selected: _icon,
          onChanged: (key) => setState(() => _icon = key),
        ),
        Gap.lg,
        _SectionLabel(l10n.categoryFormColor),
        CategoryColorPicker(
          selectedPrimary: _primary,
          onChanged: (preset) => setState(() {
            _primary = preset.primary.toARGB32();
            _secondary = preset.secondary.toARGB32();
          }),
        ),
      ],
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: context.colors.text),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox.square(
                  dimension: AppSizes.iconSm,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? l10n.actionSave : l10n.categoryFormCreate),
        ),
      ],
      onClose: () => Navigator.of(context).pop(),
    );

    // Ctrl/Cmd + Enter saves from anywhere in the form.
    final form = CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _submit,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _submit,
      },
      child: content,
    );

    if (isMobile) return Dialog.fullscreen(child: SafeArea(child: form));
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 760),
        child: form,
      ),
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.title,
    required this.preview,
    required this.fields,
    required this.actions,
    required this.onClose,
  });

  final String title;
  final Widget preview;
  final List<Widget> fields;
  final List<Widget> actions;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.sm,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: context.textStyles.subheading),
                ),
              ),
              IconButton(
                tooltip: context.l10n.actionClose,
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, size: AppSizes.iconMd),
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [preview, Gap.lg, ...fields],
            ),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: AppSpacing.xs,
            children: actions,
          ),
        ),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.name,
    required this.icon,
    required this.primary,
    required this.secondary,
  });

  final String name;
  final String icon;
  final int primary;
  final int secondary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          CategoryAvatar(
            icon: icon,
            primaryColor: primary,
            secondaryColor: secondary,
            size: 48,
          ),
          Gap.md,
          Expanded(
            child: Text(
              name.isEmpty ? context.l10n.categoryFormPreviewName : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.title.copyWith(
                color: name.isEmpty ? colors.mutedText : colors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(text, style: context.textStyles.label),
    );
  }
}
