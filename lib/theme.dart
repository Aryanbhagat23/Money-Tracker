import 'package:material_ui/material_ui.dart';

/// Brand colors and gradients. Calm navy/teal for trust, warm coral for
/// "stop", gold for encouragement. All text-on-color pairs are high contrast.
abstract final class Brand {
  static const navy = Color(0xFF0B2545);
  static const indigo = Color(0xFF1D3F8A);
  static const teal = Color(0xFF0F8B8D);
  static const mint = Color(0xFF3CCB9A);
  static const coral = Color(0xFFE5484D);
  static const crimson = Color(0xFFA51D2D);
  static const amber = Color(0xFFF5A524);
  static const gold = Color(0xFFFFD166);
  static const cloud = Color(0xFFF4F7FB);

  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy, indigo, teal],
  );
  static const danger = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [coral, crimson],
  );
  static const calm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [indigo, teal],
  );
  static const support = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B3E96), Color(0xFF8E5DB8)],
  );
  static const caution = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, amber],
  );
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Brand.indigo,
    surface: Brand.cloud,
    contrastLevel: 1.0,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: Brand.cloud,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Brand.navy,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: Brand.navy, size: 28),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        side: const BorderSide(color: Brand.indigo, width: 2),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

/// True when the user (or a test) asked the system to reduce motion.
bool reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Soft drop shadow used under cards and buttons.
List<BoxShadow> softShadow(Color color) => [
  BoxShadow(
    color: color.withValues(alpha: 0.28),
    blurRadius: 24,
    offset: const Offset(0, 10),
  ),
];
