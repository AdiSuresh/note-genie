import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:note_maker/models/base_entity.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:objectbox/objectbox.dart' as ob;

part 'model.g.dart';

@CopyWith()
class NoteCollection {
  final String name;

  const NoteCollection({
    required this.name,
  });
}

@ob.Entity()
class NoteCollectionEntity implements BaseEntity {
  @ob.Id(
    assignable: true,
  )
  @override
  final int id;

  final String name;

  final ob.ToMany<NoteEntity> notes;

  NoteCollectionEntity({
    this.id = BaseEntity.idPlaceholder,
    required this.name,
    required this.notes,
  });
}
