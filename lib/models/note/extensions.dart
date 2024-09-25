import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/models/note_collection/model.dart';

extension NoteCollectionExtension on NoteEntity {
  int _findIndex(
    int collectionId,
  ) {
    return collections.indexWhere(
      (element) {
        return element.id == collectionId;
      },
    );
  }

  void addToCollection(
    NoteCollectionEntity collection,
  ) {
    final i = _findIndex(
      collection.id,
    );
    if (i == -1) {
      collections
        ..add(
          collection,
        )
        ..applyToDb();
    }
  }

  void removeFromCollection(
    int collectionId,
  ) {
    final i = _findIndex(
      collectionId,
    );
    if (i > -1) {
      collections
        ..removeAt(
          i,
        )
        ..applyToDb();
    }
  }
}
