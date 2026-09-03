import 'package:flutter/material.dart';

ThemeData buildTheme(
  Brightness brightness, {
  int seedColor = 0xFFE84D8A,
  bool amoled = false,
  ColorScheme? dynamicColorScheme,
}) {
  final dark = brightness == Brightness.dark;
  final scheme = dynamicColorScheme ??
      ColorScheme.fromSeed(
        seedColor: Color(seedColor),
        brightness: brightness,
      );

  final scaffoldBg = amoled && dark
      ? const Color(0xFF000000)
      : dark
          ? const Color(0xFF101114)
          : const Color(0xFFF8F8FA);
  final cardBg = amoled && dark
      ? const Color(0xFF0A0A0A)
      : dark
          ? const Color(0xFF191B20)
          : Colors.white;
  final navBg = amoled && dark
      ? const Color(0xFF000000)
      : dark
          ? const Color(0xFF15161A)
          : Colors.white;
  final appBarBg = amoled && dark
      ? const Color(0xFF000000)
      : dark
          ? const Color(0xFF101114)
          : const Color(0xFFF8F8FA);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scaffoldBg,
    cardColor: cardBg,
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: navBg,
      selectedIconTheme: IconThemeData(color: scheme.primary),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: appBarBg,
      foregroundColor: scheme.onSurface,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

ThemeMode parseThemeMode(String value) {
  return switch (value) {
    'light' => ThemeMode.light,
    'system' => ThemeMode.system,
    _ => ThemeMode.dark,
  };
}
