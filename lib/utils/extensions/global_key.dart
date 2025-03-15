import 'package:flutter/material.dart';

extension GlobalKeyExtension on GlobalKey {
  RenderBox? _findRenderBox() {
    return currentContext?.findRenderObject() as RenderBox?;
  }

  Size getDimensions() {
    return _findRenderBox()?.size ?? Size.zero;
  }

  Offset? getWidgetPosition() {
    return _findRenderBox()?.localToGlobal(
      Offset.zero,
    );
  }

  Rect? findRect() {
    final renderBox = _findRenderBox();
    if (renderBox == null) {
      return null;
    }
    return renderBox.localToGlobal(
          Offset.zero,
        ) &
        renderBox.size;
  }
}
