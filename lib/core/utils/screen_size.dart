import '../constants/app_sizes.dart';

/// Layout class of the current viewport.
enum ScreenSize {
  /// Drawer navigation, single column.
  mobile,

  /// Collapsed icon sidebar.
  tablet,

  /// Full sidebar with labels.
  desktop;

  static ScreenSize fromWidth(double width) {
    if (width >= Breakpoints.desktop) return ScreenSize.desktop;
    if (width >= Breakpoints.tablet) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  bool get isMobile => this == ScreenSize.mobile;
  bool get isDesktop => this == ScreenSize.desktop;
}
