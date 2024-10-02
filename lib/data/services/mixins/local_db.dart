import 'package:meta/meta.dart';
import 'package:note_maker/data/services/objectbox_db.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:objectbox/objectbox.dart';

mixin class LocalDBServiceMixin {
  @protected
  final db = ObjectBoxDB();

  @protected
  Future<Box<NoteEntity>> get noteBox async {
    final store = await db.store;
    return store.box<NoteEntity>();
  }

  @protected
  Future<Box<NoteCollectionEntity>> get noteCollectionBox async {
    final store = await db.store;
    return store.box<NoteCollectionEntity>();
  }
}
