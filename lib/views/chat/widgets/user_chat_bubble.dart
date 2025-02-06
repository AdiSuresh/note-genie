import 'package:flutter/material.dart';
import 'package:note_maker/models/chat_message/model.dart';

class UserChatBubble extends StatelessWidget {
  final ChatMessage message;

  const UserChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Text(
          message.data,
        ),
      ),
    );
  }
}
