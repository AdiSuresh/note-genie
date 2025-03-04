import 'package:flutter/material.dart';
import 'package:note_maker/utils/extensions/tween.dart';

class PulsingDotIndicator extends StatefulWidget {
  final Duration duration;

  const PulsingDotIndicator({
    super.key,
    this.duration = const Duration(
      milliseconds: 500,
    ),
  });

  @override
  State<PulsingDotIndicator> createState() => _PulsingDotIndicatorState();
}

class _PulsingDotIndicatorState extends State<PulsingDotIndicator> {
  bool forward = true;

  @override
  Widget build(BuildContext context) {
    final tween = Tween(
      begin: 0.0,
      end: 1.0,
    );
    return TweenAnimationBuilder(
      tween: switch (forward) {
        true => tween,
        _ => tween.reversed,
      },
      duration: widget.duration,
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox.square(
              dimension: 15,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: value * 15,
              ),
            ),
          ],
        );
      },
      onEnd: () {
        if (!mounted) {
          return;
        }
        setState(() {
          forward = !forward;
        });
      },
    );
  }
}
