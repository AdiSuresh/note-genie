import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:note_maker/core/secure_storage.dart';

class ThemeModeManager with SecureStorageMixin {
  static const String _key = 'theme_mode';

  static final ThemeModeManager _instance = ThemeModeManager._();

  factory ThemeModeManager() => _instance;

  ThemeModeManager._();

  Future<ThemeMode> get() async {
    final data = await storage.read(
      key: _key,
    );
    try {
      final decoded = json.decode(
        data!,
      );
      return switch (decoded) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } catch (e) {
      // ignored
    }
    return ThemeMode.system;
  }

  Future<bool> set(ThemeMode themeMode) async {
    try {
      await storage.write(
        key: _key,
        value: json.encode(themeMode.name),
      );
      return true;
    } catch (e) {
      // ignored
    }
    return false;
  }
}
