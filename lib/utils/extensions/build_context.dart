import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  ThemeData get themeData => Theme.of(this);
  Size get screenSize => MediaQuery.of(this).size;
}
