import 'package:note_maker/data/dao_base/dao_base.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:sembast/sembast.dart';

class NoteDao extends DaoBase<Note> {
  static const storeName = 'notes';

  NoteDao({
    super.fromJson = Note.fromJson,
  }) : super(
          storeName: storeName,
        );

  Future<Stream<List<Note>>> getStreamByCollection(
    int collectionId,
  ) async {
    return store
        .query(
          finder: Finder(
            filter: Filter.inList(
              'collections',
              [
                collectionId,
              ],
            ),
          ),
        )
        .onSnapshots(
          await db,
        )
        .map(
      (event) {
        return event.map(
          (e) {
            final json = Map<String, Object?>.from(
              e.value,
            )..['id'] = e.key;
            return fromJson(
              json,
            );
          },
        ).toList();
      },
    );
  }
}
