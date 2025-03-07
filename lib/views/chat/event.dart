sealed class ChatEvent {
  const ChatEvent();
}

final class LoadDataEvent extends ChatEvent {
  const LoadDataEvent();
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
