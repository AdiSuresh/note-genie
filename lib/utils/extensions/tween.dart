import 'package:flutter/widgets.dart';

extension TweenExtension<T extends Object?> on Tween<T> {
  Tween<T> get reversed {
    return Tween(
      begin: end,
      end: begin,
    );
  }
}
