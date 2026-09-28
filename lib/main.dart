import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Clean URLs (/notes instead of /#/notes). Static hosting must rewrite
  // unknown paths to index.html so deep links survive a refresh.
  usePathUrlStrategy();

  final overrides = await bootstrap();
  runApp(ProviderScope(overrides: overrides, child: const LearningOsApp()));
}
