import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:note_maker/models/base_entity.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:objectbox/objectbox.dart';

part 'model.g.dart';

@Entity()
@CopyWith()
class NoteCollectionEntity implements BaseEntity {
  @Id()
  @override
  int id = BaseEntity.idPlaceholder;

  final String name;

  final ToMany<NoteEntity> notes;

  NoteCollectionEntity({
    this.id = BaseEntity.idPlaceholder,
    required this.name,
    required this.notes,
  });

  factory NoteCollectionEntity.untitled() {
    return NoteCollectionEntity(
      name: '',
      notes: ToMany<NoteEntity>(),
    );
  }
}
