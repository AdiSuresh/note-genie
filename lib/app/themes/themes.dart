import 'package:flutter/material.dart';

class Themes {
  static BorderRadius get borderRadius => BorderRadius.circular(15);

  static RoundedRectangleBorder get shape => RoundedRectangleBorder(
        borderRadius: borderRadius,
      );

  static ThemeData get lightTheme {
    const seedColor = Color(
      0xFFC2E7FF,
    );
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: seedColor,
        background: Colors.white,
        surface: seedColor,
        onSurface: Colors.black,
        onSurfaceVariant: Colors.blueGrey,
        error: const Color(
          0xFFBA1A1A,
        ),
        onError: Colors.white,
        onErrorContainer: const Color(
          0xFFFFDAD6,
        ),
        errorContainer: const Color(
          0xFF410002,
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2.5,
        shadowColor: Colors.black,
        color: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: Themes.shape,
      ),
    );
    return theme;
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: const Color(
          0xFFC2E7FF,
        ),
      ),
    );
  }
}
