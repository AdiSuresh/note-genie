sealed class ChatEvent {
  const ChatEvent();
}

final class SendMessage extends ChatEvent {
  final String message;

  const SendMessage({
    required this.message,
  });
}
