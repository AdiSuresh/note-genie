import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const borderRadius = BorderRadius.all(Radius.circular(15));

  final Brightness brightness;

  const AppTheme({this.brightness = Brightness.light});

  ThemeData get data {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF82A0B9),
      contrastLevel: 0.1,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    );
    final textTheme = GoogleFonts.sourceSans3TextTheme().apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: borderRadius),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
          borderRadius: borderRadius,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
          borderRadius: borderRadius,
        ),
        filled: true,
      ),
      tabBarTheme: TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        dividerHeight: 0,
        labelColor: colorScheme.onPrimary,
        labelPadding: EdgeInsets.zero,
        unselectedLabelColor: colorScheme.onSurface,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        linearMinHeight: 7.5,
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }
}
