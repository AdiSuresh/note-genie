import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:note_maker/models/chat_message/model.dart';

class BotChatBubble extends StatelessWidget {
  final ChatMessage message;

  const BotChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 7.5,
      ),
      child: GptMarkdown(
        message.data,
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}
