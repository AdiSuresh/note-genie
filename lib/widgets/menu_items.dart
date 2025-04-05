import 'package:flutter/material.dart';

class MenuItems extends StatelessWidget {
  final List<(String, VoidCallback)> items;

  const MenuItems({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2.5,
      borderRadius: BorderRadius.circular(15),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: items.indexed.map(
            (element) {
              final (i, e) = element;
              final (title, onTap) = e;
              final borderRadius = switch (i) {
                0 => BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                _ when i == items.length - 1 => BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                _ => null,
              };
              return InkWell(
                onTap: onTap,
                borderRadius: borderRadius,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      title,
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
