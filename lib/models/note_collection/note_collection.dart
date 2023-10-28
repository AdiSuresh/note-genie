import 'package:json_annotation/json_annotation.dart';

part 'note_collection.g.dart';

@JsonSerializable()
class NoteCollection {
  final int? id;
  final String name;

  const NoteCollection({
    this.id,
    required this.name,
  });

  factory NoteCollection.fromJson(
    Map<String, dynamic> json,
  ) {
    return _$NoteCollectionFromJson(
      json,
    );
  }

  Map<String, dynamic> toJson() {
    return _$NoteCollectionToJson(
      this,
    );
  }
}
