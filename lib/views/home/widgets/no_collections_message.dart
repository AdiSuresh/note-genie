import 'package:flutter/material.dart';

class NoCollectionsMessage extends StatelessWidget {
  const NoCollectionsMessage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Text(
        'No collections yet',
      ),
    );
  }
}
