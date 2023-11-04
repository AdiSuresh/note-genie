import 'package:note_maker/data/dao_base/dao_base.dart';
import 'package:note_maker/models/note/note.dart';
import 'package:sembast/sembast.dart';

class NoteDao extends DaoBase {
  static const storeName = 'notes';

  NoteDao()
      : super(
          storeName,
        );

  Future<int> insert(
    Note value,
  ) async {
    return store.add(
      await db,
      value.toJson(),
    );
  }

  Future<Map<String, Object?>?> update(
    Note value,
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

  Future<Stream<List<Note>>> get streamFuture async {
    return store
        .query()
        .onSnapshots(
          await db,
        )
        .map(
      (event) {
        return event.map(
          (e) {
            return Note.fromRecordSnapshot(
              e,
            );
          },
        ).toList();
      },
    );
  }
}
