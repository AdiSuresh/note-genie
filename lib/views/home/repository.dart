import 'package:note_maker/data/services/mixins/local_db.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/objectbox.g.dart';

class HomeRepository with LocalDBServiceMixin {
  Future<NoteCollectionEntity> putCollection(
    NoteCollectionEntity collection,
  ) async {
    final box = await noteCollectionBox;
    return collection.copyWith(
      id: box.put(
        collection,
      ),
    );
  }

  Future<bool> removeCollection(
    NoteCollectionEntity collection,
  ) async {
    final box = await noteCollectionBox;
    return box.remove(
      collection.id,
    );
  }

  Future<bool> collectionExists(
    NoteCollectionEntity collection,
  ) async {
    final box = await noteCollectionBox;
    return box.contains(
      collection.id,
    );
  }

  Future<List<NoteEntity>> fetchNotes({
    NoteCollectionEntity? currentCollection,
    String? searchQuery,
  }) async {
    final box = await noteBox;
    final builder = box.query(
      switch (searchQuery) {
        '' || null => null,
        String() => NoteEntity_.title.contains(
              searchQuery,
            ) |
            NoteEntity_.content.contains(
              searchQuery,
            ),
      },
    );
    switch (currentCollection) {
      case NoteCollectionEntity c when await collectionExists(c):
        builder.backlinkMany(
          NoteCollectionEntity_.notes,
          NoteCollectionEntity_.id.equals(
            c.id,
          ),
        );
      case _:
    }
    final query = builder.build();
    final result = query.find();
    query.close();
    return result;
  }

  Future<List<NoteCollectionEntity>> fetchNoteCollections({
    String? searchQuery,
  }) async {
    final box = await noteCollectionBox;
    final builder = box.query(
      switch (searchQuery) {
        '' || null => null,
        String() => NoteCollectionEntity_.name.contains(
            searchQuery,
          ),
      },
    );
    final query = builder.build();
    final result = query.find();
    query.close();
    return result;
  }

  Future<Stream<List<NoteCollectionEntity>>> createCollectionsStream({
    required bool Function() shouldSkip,
  }) async {
    final box = await noteCollectionBox;
    final result = box
        .query()
        .watch(
          triggerImmediately: true,
        )
        .skipWhile(
          (element) => shouldSkip(),
        )
        .map(
          (query) => query.find(),
        );
    return result;
  }
}
