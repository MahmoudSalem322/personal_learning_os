import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../utils/screen_size.dart';

extension BuildContextX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  AppShadows get shadows => Theme.of(this).extension<AppShadows>()!;

  TextTheme get textStyles => Theme.of(this).textTheme;

  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Layout class of the current viewport. Only rebuilds when the width
  /// changes, not on every media query update.
  ScreenSize get screenSize =>
      ScreenSize.fromWidth(MediaQuery.sizeOf(this).width);

  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
