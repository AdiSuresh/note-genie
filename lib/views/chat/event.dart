sealed class ChatEvent {
  const ChatEvent();
}

final class SendMessageEvent extends ChatEvent {
  final String message;

  const SendMessageEvent({
    required this.message,
  });
}
