import 'dart:math';

import 'package:flutter/material.dart';

extension ScrollControllerExtension on ScrollController {
  double get distanceFromBottom {
    final currentScrollExtent = offset;
    final maxScrollExtent = position.maxScrollExtent;
    final double result = max(
      0,
      maxScrollExtent - currentScrollExtent,
    );
    return result;
  }
}
