import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_scope.dart';
import 'data/app_store.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/launcher.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final store = AppStore(DeviceStorage(prefs));
  await store.load();
  runApp(KinfirmApp(store: store, launcher: const SystemLauncher()));
}

class KinfirmApp extends StatelessWidget {
  const KinfirmApp({super.key, required this.store, required this.launcher});

  final AppStore store;
  final Launcher launcher;

  static final ThemeData _theme = buildTheme();

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: store,
      launcher: launcher,
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) => MaterialApp(
          title: 'Kinfirm',
          debugShowCheckedModeBanner: false,
          theme: _theme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(store.textScale)),
            child: child!,
          ),
          home: store.onboarded ? const HomeScreen() : const OnboardingScreen(),
        ),
      ),
    );
  }
}
