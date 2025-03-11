import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:note_maker/models/base_entity.dart';
import 'package:note_maker/models/chat_message/model.dart';

part 'model.g.dart';

@CopyWith()
class ChatModel implements BaseEntity {
  @override
  int id = BaseEntity.idPlaceholder;
  final String? remoteId;
  final String title;
  final List<ChatMessage> messages;

  ChatModel({
    this.id = BaseEntity.idPlaceholder,
    this.remoteId,
    required this.title,
    required this.messages,
  });

  factory ChatModel.empty() {
    return ChatModel(
      id: BaseEntity.idPlaceholder,
      title: 'Untitled',
      messages: [],
    );
  }
}
