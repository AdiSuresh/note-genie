import 'package:note_maker/data/dao_base/dao_base.dart';
import 'package:note_maker/models/note_collection/model.dart';

class NoteCollectionDao extends DaoBase<NoteCollection> {
  static const storeName = 'note_collections';

  NoteCollectionDao()
      : super(
          storeName,
        );
}
