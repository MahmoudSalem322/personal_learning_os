import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../../core/widgets/app_form_dialog.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../categories/presentation/categories_providers.dart';
import '../../../categories/presentation/widgets/category_avatar.dart';
import '../../../tags/domain/tags.dart';
import '../../../tags/presentation/tag_input.dart';
import '../../domain/resource.dart';
import '../../domain/resource_draft.dart';
import '../../domain/resource_service.dart';
import '../resource_type_appearance.dart';
import '../resources_providers.dart';
import 'progress_picker.dart';

/// Add or edit a resource. Pops with the saved [Resource], or `null` when
/// cancelled.
///
/// Pasting a link is enough: the type is detected from the URL and the site
/// name becomes the title if none is given.
class ResourceFormDialog extends ConsumerStatefulWidget {
  const ResourceFormDialog({super.key, this.resource, this.initialCategoryId});

  /// The resource being edited; `null` to add a new one.
  final Resource? resource;

  /// Pre-selected category for new resources.
  final String? initialCategoryId;

  @override
  ConsumerState<ResourceFormDialog> createState() => _ResourceFormDialogState();
}

class _ResourceFormDialogState extends ConsumerState<ResourceFormDialog> {
  late final TextEditingController _url;
  late final TextEditingController _title;
  late final TextEditingController _description;
  late ResourceType _type;
  late String? _categoryId;
  late List<String> _tags;
  late int _progress;
  late bool _favorite;

  /// Once the user picks a type, stop auto-detecting it from the URL.
  late bool _typeChosen;
  Set<ResourceFieldError> _errors = const {};
  bool _saving = false;

  bool get _isEditing => widget.resource != null;

  @override
  void initState() {
    super.initState();
    final r = widget.resource;
    _url = TextEditingController(text: r?.url ?? '');
    _title = TextEditingController(text: r?.title ?? '');
    _description = TextEditingController(text: r?.description ?? '');
    _type = r?.type ?? ResourceType.website;
    _typeChosen = r != null;
    _categoryId = r?.categoryId ?? widget.initialCategoryId;
    _tags = r?.tags ?? const [];
    _progress = r?.progress ?? 0;
    _favorite = r?.isFavorite ?? false;
    _url.addListener(_onUrlChanged);
    _title.addListener(() => _clearErrors({ResourceFieldError.titleRequired}));
  }

  @override
  void dispose() {
    _url.dispose();
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  void _onUrlChanged() {
    _clearErrors({
      ResourceFieldError.urlInvalid,
      ResourceFieldError.titleRequired,
    });
    if (_typeChosen) return;
    final normalized = UrlUtils.normalize(_url.text);
    if (normalized == null || normalized.isEmpty) return;
    final detected = ResourceType.detect(normalized);
    if (detected != _type) setState(() => _type = detected);
  }

  void _clearErrors(Set<ResourceFieldError> fixed) {
    if (_errors.any(fixed.contains)) {
      setState(() => _errors = _errors.difference(fixed));
    }
  }

  ResourceDraft get _draft => ResourceDraft(
    title: _title.text,
    description: _description.text,
    url: _url.text,
    type: _type,
    categoryId: _categoryId,
    tags: _tags,
    progress: _progress,
    isFavorite: _favorite,
  );

  Future<void> _submit() async {
    if (_saving) return;
    final errors = ResourceService.validate(_draft);
    if (errors.isNotEmpty) {
      setState(() => _errors = errors);
      return;
    }
    setState(() => _saving = true);
    final service = ref.read(resourceServiceProvider);
    try {
      final saved = _isEditing
          ? await service.update(widget.resource!.id, _draft)
          : await service.create(_draft);
      if (mounted) Navigator.of(context).pop(saved);
    } on ResourceValidationException catch (e) {
      if (mounted) setState(() => _errors = e.errors);
    } on AppException {
      if (mounted) AppToast.error(context, context.l10n.resourceSaveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _titleError() {
    final l10n = context.l10n;
    if (_errors.contains(ResourceFieldError.titleRequired)) {
      return l10n.resourceTitleRequired;
    }
    if (_errors.contains(ResourceFieldError.titleTooLong)) {
      return l10n.validationTooLong(ResourceRules.titleMaxLength);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = ref.watch(categoriesProvider).value ?? const [];
    // A pre-selected category may have been deleted meanwhile.
    final categoryValue = categories.any((c) => c.id == _categoryId)
        ? _categoryId
        : null;

    return AppFormDialog(
      title: _isEditing
          ? l10n.resourceFormEditTitle
          : l10n.resourceFormCreateTitle,
      submitLabel: _isEditing ? l10n.actionSave : l10n.resourceFormCreate,
      onSubmit: _submit,
      saving: _saving,
      maxWidth: 580,
      children: [
        TextField(
          controller: _url,
          autofocus: !_isEditing,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.resourceFormUrl,
            hintText: l10n.resourceFormUrlHint,
            prefixIcon: const Icon(Icons.link_rounded, size: AppSizes.iconMd),
            errorText: _errors.contains(ResourceFieldError.urlInvalid)
                ? l10n.resourceUrlInvalid
                : null,
          ),
        ),
        Gap.md,
        TextField(
          controller: _title,
          autofocus: _isEditing,
          maxLength: ResourceRules.titleMaxLength,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.resourceFormTitle,
            hintText: l10n.resourceFormTitleHint,
            errorText: _titleError(),
            counterText: '',
          ),
        ),
        Gap.md,
        TextField(
          controller: _description,
          minLines: 2,
          maxLines: 5,
          maxLength: ResourceRules.descriptionMaxLength,
          decoration: InputDecoration(
            labelText: l10n.resourceFormDescription,
            hintText: l10n.resourceFormDescriptionHint,
            alignLabelWithHint: true,
            errorText: _errors.contains(ResourceFieldError.descriptionTooLong)
                ? l10n.validationTooLong(ResourceRules.descriptionMaxLength)
                : null,
          ),
        ),
        Gap.sm,
        AppFormLabel(l10n.resourceFormType),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final type in ResourceType.values)
              ChoiceChip(
                avatar: Icon(type.icon, size: AppSizes.iconSm),
                label: Text(type.label(l10n)),
                selected: type == _type,
                showCheckmark: false,
                onSelected: (_) => setState(() {
                  _type = type;
                  _typeChosen = true;
                }),
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
        TagInput(
          tags: _tags,
          onChanged: (tags) => setState(() {
            _tags = tags;
            _errors = _errors.difference({ResourceFieldError.tooManyTags});
          }),
          label: l10n.resourceFormTags,
          hint: l10n.resourceFormTagsHint,
          removeTooltip: l10n.resourceFormRemoveTag,
          suggestions: ref.watch(allTagsProvider),
          errorText: _errors.contains(ResourceFieldError.tooManyTags)
              ? l10n.resourceTooManyTags(TagRules.maxPerItem)
              : null,
        ),
        Gap.lg,
        AppFormLabel(l10n.resourceFormProgress),
        ProgressPicker(
          value: _progress,
          onChanged: (value) => setState(() => _progress = value),
          onCommitted: (value) => setState(() => _progress = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _favorite,
          onChanged: (value) => setState(() => _favorite = value),
          title: Text(l10n.resourceFormFavorite),
          secondary: Icon(
            _favorite ? Icons.star_rounded : Icons.star_outline_rounded,
            color: _favorite
                ? context.colors.warning
                : context.colors.mutedText,
          ),
        ),
      ],
    );
  }
}
