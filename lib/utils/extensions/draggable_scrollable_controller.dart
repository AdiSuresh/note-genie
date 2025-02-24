import 'package:flutter/widgets.dart';

extension AnimationStatusExtension on DraggableScrollableController {
  Future<bool> isAnimating() async {
    try {
      final s1 = size;
      await Future.delayed(
        const Duration(
          milliseconds: 25,
        ),
      );
      final s2 = size;
      return s1 != s2;
    } catch (e) {
      return false;
    }
  }
}
