import 'package:copy_with_extension/copy_with_extension.dart';

part 'model.g.dart';

enum MessengerType {
  user,
  bot,
}

@CopyWith()
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
