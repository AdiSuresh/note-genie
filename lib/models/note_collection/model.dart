import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:note_maker/models/model_base.dart';

part 'model.g.dart';

@JsonSerializable()
@CopyWith()
class NoteCollection extends ModelBase {
  final String name;

  const NoteCollection({
    super.id,
    required this.name,
  });

  factory NoteCollection.fromJson(
    Map<String, dynamic> json,
  ) {
    return _$NoteCollectionFromJson(
      json,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return _$NoteCollectionToJson(
      this,
    );
  }
}
