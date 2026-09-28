/// URL paths of the app.
///
/// Features navigate with these constants (`context.go(AppRoutes.notes)`)
/// instead of string literals. Detail routes (e.g. `/resources/:id`) get a
/// path builder here when their phase is implemented.
abstract final class AppRoutes {
  static const String root = '/';
  static const String dashboard = '/dashboard';
  static const String categories = '/categories';
  static const String resources = '/resources';
  static const String notes = '/notes';
  static const String tasks = '/tasks';
  static const String favorites = '/favorites';
  static const String settings = '/settings';
}
