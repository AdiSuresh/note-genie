import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sembast/sembast.dart';

part 'note.g.dart';

@JsonSerializable()
@CopyWith()
class Note {
  final int? id;
  final String title;
  final List<dynamic> content;
  final Set<int> collections;

  const Note({
    this.id,
    required this.title,
    required this.content,
    required this.collections,
  });

  factory Note.empty() {
    return const Note(
      title: '',
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

  Map<String, dynamic> toJson() {
    return _$NoteToJson(
      this,
    );
  }

  factory Note.fromRecordSnapshot(
    RecordSnapshot<int, Map<String, Object?>> snapshot,
  ) {
    return Note.fromJson(
      snapshot.value,
    ).copyWith(
      id: snapshot.key,
    );
  }
}
