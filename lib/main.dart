import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_scope.dart';
import 'data/app_store.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/launcher.dart';

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
          theme: _theme(),
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

  ThemeData _theme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1F4E8C),
      contrastLevel: 1.0,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      cardTheme: const CardThemeData(margin: EdgeInsets.symmetric(vertical: 6)),
    );
  }
}
