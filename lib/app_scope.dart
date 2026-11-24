import 'package:material_ui/material_ui.dart';

import 'data/app_store.dart';
import 'services/launcher.dart';

/// Makes the [AppStore] and [Launcher] available to every screen and
/// rebuilds dependents when the store changes.
class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({
    super.key,
    required AppStore store,
    required this.launcher,
    required super.child,
  }) : super(notifier: store);

  final Launcher launcher;

  static AppScope _of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope above this widget');
    return scope!;
  }

  static AppStore store(BuildContext context) => _of(context).notifier!;
  static Launcher launcherOf(BuildContext context) => _of(context).launcher;

  /// Opens [uri], showing a message if the phone can't handle it.
  static Future<void> open(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await launcherOf(context).open(uri);
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Sorry, this phone could not open that.')),
      );
    }
  }
}
