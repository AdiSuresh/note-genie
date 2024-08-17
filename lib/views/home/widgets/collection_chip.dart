import 'package:flutter/material.dart';
import 'package:note_maker/app/themes/themes.dart';

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
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        customBorder: Themes.shape,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: child,
        ),
      ),
    );
  }
}
