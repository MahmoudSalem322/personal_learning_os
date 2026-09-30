/// URL paths of the app.
///
/// Features navigate with these constants (`context.go(AppRoutes.notes)`)
/// instead of string literals. Detail routes get a path builder here when
/// their phase is implemented.
abstract final class AppRoutes {
  static const String root = '/';
  static const String dashboard = '/dashboard';
  static const String categories = '/categories';
  static const String resources = '/resources';
  static const String notes = '/notes';
  static const String tasks = '/tasks';
  static const String favorites = '/favorites';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  /// Path parameter name of detail routes.
  static const String idParam = 'id';

  static String category(String id) => '$categories/${Uri.encodeComponent(id)}';

  static String resource(String id) => '$resources/${Uri.encodeComponent(id)}';

  static String note(String id) => '$notes/${Uri.encodeComponent(id)}';

  static String task(String id) => '$tasks/${Uri.encodeComponent(id)}';
}
