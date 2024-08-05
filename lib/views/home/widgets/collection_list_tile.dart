import 'package:flutter/material.dart';
import 'package:note_maker/app/themes/themes.dart';

class CollectionListTile extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const CollectionListTile({
    super.key,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        customBorder: Themes.shape,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.5),
          child: child,
        ),
      ),
    );
  }
}
