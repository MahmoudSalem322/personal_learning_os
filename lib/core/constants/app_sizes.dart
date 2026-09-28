/// Layout dimensions that are not part of the spacing scale.
abstract final class AppSizes {
  /// Width of the sidebar on desktop.
  static const double sidebarExpandedWidth = 260;

  /// Width of the icon-only sidebar on tablet.
  static const double sidebarCollapsedWidth = 72;

  /// Width of the navigation drawer on mobile.
  static const double drawerWidth = 288;

  /// Maximum width of page content so long lines stay readable.
  static const double contentMaxWidth = 1200;

  /// Maximum width of centered states (empty, error, not found).
  static const double stateMaxWidth = 440;

  static const double navItemHeight = 40;
  static const double mobileTopBarHeight = 56;

  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;
}

/// Width thresholds for the responsive layout.
abstract final class Breakpoints {
  /// Below this width the app uses the mobile layout.
  static const double tablet = 640;

  /// At or above this width the app uses the desktop layout.
  static const double desktop = 1100;
}
