sealed class ChatEvent {
  const ChatEvent();
}

final class InitEvent extends ChatEvent {
  const InitEvent();
}

final class LoadAllChatsEvent extends ChatEvent {
  const LoadAllChatsEvent();
}

final class LoadChatEvent extends ChatEvent {
  final String? id;

  const LoadChatEvent({
    this.id,
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
