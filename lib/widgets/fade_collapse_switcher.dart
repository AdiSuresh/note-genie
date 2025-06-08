import 'package:flutter/widgets.dart';

class FadeCollapseSwitcher extends StatelessWidget {
  final bool visibility;
  final Axis axis;
  final Duration duration;
  final Widget? child;

  const FadeCollapseSwitcher({
    super.key,
    required this.visibility,
    this.axis = Axis.vertical,
    this.duration = const Duration(
      milliseconds: 125,
    ),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        final t1 = FadeTransition(
          opacity: animation,
          child: child,
        );
        final t2 = SizeTransition(
          sizeFactor: animation,
          axis: axis,
          child: t1,
        );
        return t2;
      },
      child: switch (visibility) {
        true => KeyedSubtree(
            key: const ValueKey(
              true,
            ),
            child: child ?? const SizedBox(),
          ),
        _ => const SizedBox(
            key: ValueKey(
              false,
            ),
          ),
      },
    );
  }
}
