import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:http/http.dart';
import 'package:note_maker/models/chat_message/model.dart';

part 'state.g.dart';

sealed class ChatState {
  const ChatState();
}

@CopyWith()
final class IdleState extends ChatState {
  final List<ChatMessage> messages;
  final bool showButton;

  const IdleState({
    required this.messages,
    required this.showButton,
  });
}

@CopyWith()
final class GeneratingResponseState {
  final IdleState prevState;
  final StreamedResponse response;

  const GeneratingResponseState({
    required this.prevState,
    required this.response,
  });
}
