import 'dart:math';

import 'package:flutter/material.dart';

extension ScrollControllerExtension on ScrollController {
  double findDistanceFromBottom([
    bool reverse = false,
  ]) {
    if (reverse) {
      return offset.abs();
    }
    final currentScrollExtent = offset;
    final maxScrollExtent = position.maxScrollExtent;
    final double result = max(
      0,
      maxScrollExtent - currentScrollExtent,
    );
    return result;
  }
}
