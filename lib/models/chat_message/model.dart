enum MessengerType {
  user,
  bot,
}

class ChatMessage {
  final String data;
  final MessengerType role;
  final DateTime timestamp;

  ChatMessage({
    required this.data,
    required this.role,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
