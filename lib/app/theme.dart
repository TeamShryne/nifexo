import 'package:flutter/material.dart';

ThemeData buildNifexoTheme({required Brightness brightness}) {
  const seed = Color(0xFF0E7C66);
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  final isDark = brightness == Brightness.dark;

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: isDark
        ? const Color(0xFF0F1720)
        : const Color(0xFFF5F7F3),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: scheme.surface,
      foregroundColor: isDark ? Colors.white : const Color(0xFF0F1720),
      surfaceTintColor: scheme.surfaceTint,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF17212B) : Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
      indicatorColor: isDark
          ? const Color(0xFF184B40)
          : const Color(0xFFD6F2E6),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: seed,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF17212B) : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
