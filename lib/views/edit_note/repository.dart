import 'package:note_maker/data/services/mixins/local_db.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/objectbox.g.dart';

class EditNoteRepository with LocalDBServiceMixin {
  Future<NoteEntity> putNote(
    NoteEntity note,
  ) async {
    final box = await noteBox;
    return note.copyWith(
      id: box.put(
        note,
      ),
    );
  }

  Future<List<NoteCollectionEntity>> getUnlinkedCollections(
    List<NoteCollectionEntity> linkedCollections,
  ) async {
    final linkedCollectionIds = linkedCollections.map(
      (element) {
        return element.id;
      },
    ).toList(
      growable: false,
    );
    final box = await noteCollectionBox;
    final query = box
        .query(
          NoteCollectionEntity_.id.notOneOf(
            linkedCollectionIds,
          ),
        )
        .build();
    final result = query.find();
    query.close();
    return result;
  }
}
