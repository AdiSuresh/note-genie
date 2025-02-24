import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:note_maker/models/chat_message/model.dart';

part 'state.g.dart';

sealed class ChatState {}

@CopyWith()
final class IdleState extends ChatState {
  final List<ChatMessage> messages;
  final bool showButton;

  IdleState({
    required this.messages,
    required this.showButton,
  });
}
