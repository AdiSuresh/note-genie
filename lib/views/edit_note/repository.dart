import 'package:note_maker/data/objectbox_db.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:objectbox/objectbox.dart';

class EditNoteRepository {
  Future<Box<NoteEntity>> get box async {
    final store = await ObjectBoxDB().store;
    return store.box<NoteEntity>();
  }

  Future<NoteEntity> saveNote(
    NoteEntity note,
  ) async {
    final box = await this.box;
    return note.copyWith(
      id: box.put(
        note,
      ),
    );
  }
}
