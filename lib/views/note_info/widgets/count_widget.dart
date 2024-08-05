import 'package:flutter/material.dart';
import 'package:note_maker/utils/extensions/build_context.dart';

class CountWidget extends StatelessWidget {
  final int count;
  final String text;

  const CountWidget({
    super.key,
    required this.count,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.themeData.textTheme;
    return Card(
      elevation: 2.5,
      margin: const EdgeInsets.all(7.5 / 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 7.5,
          horizontal: 15,
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: '$text: ',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
            children: <TextSpan>[
              TextSpan(
                text: count.toString(),
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
