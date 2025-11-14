import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/services/theme_mode_manager.dart';

class ThemeModeCubit extends Cubit<ThemeMode> {
  @protected
  static final manager = ThemeModeManager();

  ThemeModeCubit() : super(ThemeMode.system);

  Future<void> update(ThemeMode themeMode) async {
    if (state == themeMode) {
      return;
    }
    emit(themeMode);
    await manager.set(themeMode);
  }

  Future<void> set() async {
    final themeMode = await manager.get();
    emit(themeMode);
  }
}
