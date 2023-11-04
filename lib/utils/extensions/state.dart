import 'package:flutter/material.dart';

extension ProvidersFromStateExtension on State {
  ThemeData get themeData => Theme.of(context);
  Size get screenSize => MediaQuery.of(context).size;
}
