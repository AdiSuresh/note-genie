import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

@JsonSerializable()
class Note {
  final int? id;
  final String title;
  final Set<int> collections;

  const Note({
    this.id,
    required this.title,
    required this.collections,
  });

  factory Note.fromJson(
    Map<String, dynamic> json,
  ) {
    return _$NoteFromJson(
      json,
    );
  }

  Map<String, dynamic> toJson() {
    return _$NoteToJson(
      this,
    );
  }
}
