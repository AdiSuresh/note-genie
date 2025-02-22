import 'package:flutter/material.dart';
import 'package:note_maker/models/chat_message/model.dart';
import 'package:note_maker/views/chat/widgets/user_chat_bubble.dart';

class ChatBubbleWrapper extends StatelessWidget {
  final ChatMessage message;

  const ChatBubbleWrapper({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: switch (message.role) {
        MessengerType.bot => Alignment.centerLeft,
        MessengerType.user => Alignment.centerRight,
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 7.5,
          horizontal: 15,
        ),
        child: UserChatBubble(
          message: message,
        ),
      ),
    );
  }
}
