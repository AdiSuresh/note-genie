import 'package:flutter/material.dart';
import 'package:note_maker/utils/extensions/build_context.dart';

class NewChatPlaceholder extends StatelessWidget {
  const NewChatPlaceholder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assistant,
            size: 45,
            color: Colors.blueAccent,
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            'What can I help with?',
            style: context.themeData.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
