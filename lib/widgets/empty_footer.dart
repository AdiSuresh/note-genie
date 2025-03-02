import 'package:flutter/material.dart';

class EmptyFooter extends StatelessWidget {
  const EmptyFooter({
    super.key,
    this.fraction = .15,
  });

  final double fraction;

  @override
  Widget build(context) {
    final screenSize = MediaQuery.of(context).size;
    return SizedBox(
      height: screenSize.height * fraction,
    );
  }
}
