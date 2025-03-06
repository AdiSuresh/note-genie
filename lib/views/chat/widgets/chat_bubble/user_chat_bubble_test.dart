import 'dart:math';

import 'package:flutter/material.dart';
import 'package:note_maker/models/chat_message/model.dart';

class UserChatBubbleTest extends StatelessWidget {
  final ChatMessage message;

  const UserChatBubbleTest({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final chatBubble = Material(
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
    return TweenAnimationBuilder(
      tween: Tween(
        begin: 1.0,
        end: 0.0,
      ),
      duration: const Duration(
        milliseconds: 250,
      ),
      builder: (context, value, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateX(
              pi * value / 8,
            )
            ..rotateY(
              pi * value / 16,
            )
            ..scale(
              1 - 0.05 * value,
            )
            ..translate(
              15 * value,
            ),
          child: Opacity(
            opacity: 1 - value,
            child: chatBubble,
          ),
        );
      },
    );
  }
}
