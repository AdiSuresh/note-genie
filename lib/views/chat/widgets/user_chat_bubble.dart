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
      elevation: 2.5,
      color: Colors.lightBlue[100],
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Text(
          message.data,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
