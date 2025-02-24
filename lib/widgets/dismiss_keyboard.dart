import 'package:flutter/material.dart';
import 'package:note_maker/utils/ui_utils.dart';

class DismissKeyboard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const DismissKeyboard({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        UiUtils.dismissKeyboard(
          context,
        );
        onTap?.call();
      },
      child: child,
    );
  }
}
