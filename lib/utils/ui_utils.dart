import 'package:flutter/material.dart';

class UiUtils {
  static void dismissKeyboard(
    BuildContext context,
  ) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}
