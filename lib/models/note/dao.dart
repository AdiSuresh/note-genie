import 'package:note_maker/data/dao_base/dao_base.dart';
import 'package:note_maker/models/note/model.dart';

class NoteDao extends DaoBase<Note> {
  static const storeName = 'notes';

  NoteDao({
    super.fromJson = Note.fromJson,
  }) : super(
          storeName: storeName,
        );
}
