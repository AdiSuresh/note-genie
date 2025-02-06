import 'package:flutter/material.dart';

class AppBarWrapper extends StatelessWidget {
  final Widget child;

  const AppBarWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(15).copyWith(
        top: 7.5,
        bottom: 0,
      ),
      child: child,
    );
  }
}
