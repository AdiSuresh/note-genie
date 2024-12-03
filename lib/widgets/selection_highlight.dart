import 'package:flutter/material.dart';

class SelectionHighlight extends StatelessWidget {
  static const _animationDuration = Duration(
    milliseconds: 150,
  );

  final bool selected;
  final double scaleFactor;
  final Widget child;

  const SelectionHighlight({
    super.key,
    required this.selected,
    this.scaleFactor = 1.05,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scale = selected ? scaleFactor : 1.0;
    return AnimatedContainer(
      duration: _animationDuration,
      decoration: BoxDecoration(
        border: Border.all(
          color: switch (selected) {
            true => Colors.blueGrey.withOpacity(
                .5,
              ),
            _ => Colors.transparent,
          },
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(
          15,
        ),
      ),
      transform: Transform.scale(
        scale: scale,
      ).transform,
      transformAlignment: Alignment.center,
      child: child,
    );
  }
}
