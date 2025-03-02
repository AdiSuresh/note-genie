import 'package:flutter/material.dart';

class CollectionChip extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const CollectionChip({
    super.key,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: child,
        ),
      ),
    );
  }
}
