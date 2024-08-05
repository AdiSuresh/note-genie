import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:note_maker/models/model_base.dart';

part 'model.g.dart';

@JsonSerializable()
@CopyWith()
class Note extends ModelBase {
  final String title;
  final List<dynamic> content;
  final Set<int> collections;

  const Note({
    super.id,
    required this.title,
    required this.content,
    required this.collections,
  });

  factory Note.empty() {
    return const Note(
      title: 'Untitled',
      content: [],
      collections: {},
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json,
  ) {
    return _$NoteFromJson(
      json,
    );
  }

  String get contentAsText {
    return Document.fromJson(
      content,
    ).toPlainText().trim();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$NoteToJson(
      this,
    );
  }
}
