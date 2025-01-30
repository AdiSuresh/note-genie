import 'package:note_maker/models/chat_message/model.dart';

sealed class ChatState {}

final class IdleState extends ChatState {
  final List<ChatMessage> messages;

  IdleState({
    required this.messages,
  });
}
