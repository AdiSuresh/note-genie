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

sealed class MessageProcessingState extends ChatState {
  final IdleState prevState;
  final Client client;

  const MessageProcessingState({
    required this.prevState,
    required this.client,
  });
}

final class SendingMessageState extends MessageProcessingState {
  const SendingMessageState({
    required super.prevState,
    required super.client,
  });
}

@CopyWith()
final class ReceivingMessageState extends MessageProcessingState {
  final StreamedResponse response;

  const ReceivingMessageState({
    required super.prevState,
    required super.client,
    required this.response,
  });
}
