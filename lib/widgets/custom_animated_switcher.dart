import 'package:flutter/material.dart';

class CustomAnimatedSwitcher extends StatelessWidget {
  static const _animationDuration = Duration(
    milliseconds: 150,
  );

  final Widget child;

  const CustomAnimatedSwitcher({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _animationDuration,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(
              begin: 0.975,
              end: 1.0,
            ).animate(
              animation,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
