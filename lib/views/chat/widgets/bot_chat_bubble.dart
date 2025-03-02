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
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: GptMarkdown(
          message.data,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
