import 'package:flutter/material.dart';

ThemeData buildTheme(Brightness brightness, {int seedColor = 0xFFE84D8A}) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: Color(seedColor),
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        dark ? const Color(0xFF101114) : const Color(0xFFF8F8FA),
    cardColor: dark ? const Color(0xFF191B20) : Colors.white,
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: dark ? const Color(0xFF15161A) : Colors.white,
      selectedIconTheme: IconThemeData(color: scheme.primary),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: dark ? const Color(0xFF101114) : const Color(0xFFF8F8FA),
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
