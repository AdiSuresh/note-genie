import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:note_maker/models/base_entity.dart';
import 'package:note_maker/models/model_base.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:objectbox/objectbox.dart' as ob;

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

@ob.Entity()
class NoteCollectionEntity implements BaseEntity<NoteCollection> {
  @ob.Id(
    assignable: true,
  )
  @override
  final int id;

  @ob.Transient()
  @override
  NoteCollection get data {
    return NoteCollection(
      name: name,
    );
  }

  final String name;

  final ob.ToMany<NoteEntity> notes;

  NoteCollectionEntity({
    required this.id,
    required this.name,
    required this.notes,
  });
}
