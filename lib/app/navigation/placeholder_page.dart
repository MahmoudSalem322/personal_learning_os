import 'package:material_ui/material_ui.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/app_state_view.dart';
import 'app_destination.dart';

/// Temporary content for a section whose phase has not been built yet.
/// Each phase replaces its destination's placeholder in the router.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({required this.destination, super.key});

  final AppDestination destination;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = destination.label(l10n);
    return AppPage(
      title: label,
      subtitle: destination.subtitle(l10n),
      body: AppStateView(
        icon: destination.icon,
        title: l10n.comingSoonTitle(label),
        message: l10n.comingSoonMessage,
      ),
    );
  }
}
