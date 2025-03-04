import 'package:note_maker/models/base_entity.dart';
import 'package:note_maker/models/chat_message/model.dart';

class ChatModel extends BaseEntity {
  final String title;
  final List<ChatMessage> messages;

  ChatModel({
    required super.id,
    required this.title,
    required this.messages,
  });

  factory ChatModel.empty() {
    return ChatModel(
      id: BaseEntity.idPlaceholder,
      title: '',
      messages: [],
    );
  }
}
