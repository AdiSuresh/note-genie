import 'package:note_maker/data/services/mixins/local_db.dart';
import 'package:note_maker/models/note_collection/model.dart';

class HomeRepository with LocalDBServiceMixin {
  Future<Stream<List<NoteCollectionEntity>>> createCollectionsStream() async {
    final box = await noteCollectionBox;
    final result = box
        .query()
        .watch(
          triggerImmediately: true,
        )
        .map(
          (query) => query.find(),
        );
    return result;
  }
}
