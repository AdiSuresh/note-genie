sealed class ChatEvent {
  const ChatEvent();
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

sealed class RenameChatEvent extends ChatEvent {
  final String title;

  const RenameChatEvent({
    required this.title,
  });
}

final class RenameCurrentChatEvent extends RenameChatEvent {
  const RenameCurrentChatEvent({
    required super.title,
  });
}

final class RenameChatFromListEvent extends RenameChatEvent {
  final int index;

  const RenameChatFromListEvent({
    required super.title,
    required this.index,
  });
}
