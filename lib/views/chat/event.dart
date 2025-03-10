import 'package:note_maker/models/chat/model.dart';

sealed class ChatEvent {
  const ChatEvent();
}

final class LoadDataEvent extends ChatEvent {
  final ChatModel chat;

  const LoadDataEvent({
    required this.chat,
  });
}

final class SendMessageEvent extends ChatEvent {
  final String message;

  const SendMessageEvent({
    required this.message,
  });
}

final class UpdateButtonVisibilityEvent extends ChatEvent {
  final bool value;

  const UpdateButtonVisibilityEvent({
    required this.value,
  });
}
