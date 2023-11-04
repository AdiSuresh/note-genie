import 'package:note_maker/data/dao_base/dao_base.dart';
import 'package:note_maker/models/note_collection/note_collection.dart';
import 'package:sembast/sembast.dart';

class NoteCollectionDao extends DaoBase {
  static const storeName = 'note_collections';

  NoteCollectionDao()
      : super(
          storeName,
        );

  Future<int> insert(
    NoteCollection value,
  ) async {
    return store.add(
      await db,
      value.toJson(),
    );
  }

  Future<Map<String, Object?>?> update(
    NoteCollection value,
  ) async {
    if (value.id == null) {
      return null;
    }
    return store
        .record(
          value.id!,
        )
        .update(
          await db,
          value.toJson(),
        );
  }

  Future<Stream<List<NoteCollection>>> get streamFuture async {
    return store
        .query()
        .onSnapshots(
          await db,
        )
        .map(
      (event) {
        return event.map(
          (e) {
            return NoteCollection.fromRecordSnapshot(
              e,
            );
          },
        ).toList();
      },
    );
  }
}
