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

  void removeFromCollection(
    int collectionId,
  ) {
    final i = _findIndex(
      collectionId,
    );
    switch (i) {
      case > -1:
        collections
          ..removeAt(
            i,
          )
          ..applyToDb();
      case _:
    }
  }

  void addToCollection(
    NoteCollectionEntity collection,
  ) {
    final i = _findIndex(
      collection.id,
    );
    switch (i) {
      case -1:
        collections
          ..add(
            collection,
          )
          ..applyToDb();
      case _:
    }
  }
}
