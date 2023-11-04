import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sembast/sembast.dart';

part 'note_collection.g.dart';

@JsonSerializable()
@CopyWith()
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

  factory NoteCollection.fromRecordSnapshot(
    RecordSnapshot<int, Map<String, Object?>> snapshot,
  ) {
    return NoteCollection.fromJson(
      snapshot.value,
    ).copyWith(
      id: snapshot.key,
    );
  }
}
