import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:http/http.dart';
import 'package:note_maker/models/chat/model.dart';
import 'package:note_maker/models/chat_message/model.dart';
import 'package:note_maker/models/future_data/model.dart';

part 'state.g.dart';

sealed class ChatState {
  const ChatState();
}

@CopyWith()
final class IdleState extends ChatState {
  final AsyncData<List<ChatModel>> allChats;
  final AsyncData<ChatModel> chat;
  final bool showButton;

  const IdleState({
    required this.allChats,
    required this.chat,
    required this.showButton,
  });
}

// final class LoadingState extends ChatState {
//   final bool allChats;
//   final bool messages;

//   const LoadingState({
//     this.allChats = false,
//     this.messages = false,
//   });
// }

sealed class NonIdleState extends ChatState {
  final IdleState previousState;

  const NonIdleState({
    required this.previousState,
  });
}

sealed class MessageProcessingState extends NonIdleState {
  final Client client;

  const MessageProcessingState({
    required super.previousState,
    required this.client,
  });
}

@CopyWith()
final class SendingMessageState extends MessageProcessingState {
  const SendingMessageState({
    required super.previousState,
    required super.client,
  });
}

@CopyWith()
final class ReceivingMessageState extends MessageProcessingState {
  final StreamedResponse response;
  final ChatMessage message;

  const ReceivingMessageState({
    required super.previousState,
    required super.client,
    required this.response,
    required this.message,
  });
}
