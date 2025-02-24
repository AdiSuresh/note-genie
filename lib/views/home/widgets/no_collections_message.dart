import 'package:flutter/material.dart';

class NoCollectionsMessage extends StatelessWidget {
  final String? message;

  const NoCollectionsMessage({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Text(
        message ?? 'No collections yet',
      ),
    );
  }
}
