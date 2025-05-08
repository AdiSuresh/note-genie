import 'package:flutter/material.dart';
import 'package:note_maker/utils/extensions/tween.dart';

class ThreeDotIndicator extends StatefulWidget {
  final Duration duration;

  const ThreeDotIndicator({
    super.key,
    this.duration = const Duration(
      milliseconds: 125,
    ),
  });

  @override
  State<ThreeDotIndicator> createState() => _ThreeDotIndicatorState();
}

class _ThreeDotIndicatorState extends State<ThreeDotIndicator> {
  static const s0 = (false, false, false);
  static const s1 = (true, false, false);
  static const s2 = (false, true, false);
  static const s3 = (false, false, true);

  var state = s1;

  void mutate() {
    switch (state) {
      case s0:
        forward = !forward;
        if (forward) {
          state = s1;
        }
      case s1:
        forward = !forward;
        if (forward) {
          state = s2;
        }
      case s2:
        forward = !forward;
        if (forward) {
          state = s3;
        }
      case _:
        forward = !forward;
        if (forward) {
          state = s0;
        }
    }
  }

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
      curve: Curves.ease,
      builder: (context, value, child) {
        final (s1, s2, s3) = state;
        return Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox.square(
              dimension: 7.5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(
                  yOffset: s1 ? -5 * value : 0.0,
                ),
                const SizedBox(
                  width: 2.5,
                ),
                _Dot(
                  yOffset: s2 ? -5 * value : 0.0,
                ),
                const SizedBox(
                  width: 2.5,
                ),
                _Dot(
                  yOffset: s3 ? -5 * value : 0.0,
                ),
              ],
            ),
          ],
        );
      },
      onEnd: () {
        if (!mounted) {
          return;
        }
        setState(() {
          mutate();
        });
      },
    );
  }
}

class _Dot extends StatelessWidget {
  final double yOffset;

  const _Dot({
    required this.yOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..translate(
          0.0,
          yOffset,
          0.0,
        ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: const SizedBox.square(
          dimension: 7.5,
        ),
      ),
    );
  }
}
