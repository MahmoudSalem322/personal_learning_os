import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_toast.dart';

/// Runs a settings update and shows an error toast if it can't be saved.
Future<void> applyPreference(
  BuildContext context,
  Future<void> Function() update,
) async {
  try {
    await update();
  } on AppException {
    if (context.mounted) {
      AppToast.error(context, context.l10n.settingsSaveError);
    }
  }
}
