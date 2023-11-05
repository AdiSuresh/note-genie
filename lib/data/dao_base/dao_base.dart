import 'package:note_maker/data/local_db.dart';
import 'package:note_maker/models/model_base.dart';
import 'package:sembast/sembast.dart';

class DaoBase<T extends ModelBase> {
  final StoreRef<int, Map<String, Object?>> _store;
  final T Function(Map<String, Object?>) fromJson;

  Future<Database> get db async => await LocalDatabase.instance.database;

  StoreRef<int, Map<String, Object?>> get store => _store;

  DaoBase({
    required String storeName,
    required this.fromJson,
  }) : _store = intMapStoreFactory.store(
          storeName,
        );

  Future<int> create(
    T value,
  ) async {
    return store.add(
      await db,
      value.toJson(),
    );
  }

  Future<Map<String, Object?>?> update(
    T value,
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

  Future<int?> delete(
    T value,
  ) async {
    if (value.id == null) {
      return null;
    }
    return store
        .record(
          value.id!,
        )
        .delete(
          await db,
        );
  }

  Future<Stream<List<T>>> get getStream async {
    return store
        .query()
        .onSnapshots(
          await db,
        )
        .map(
      (event) {
        return event.map(
          (e) {
            final map = <String, dynamic>{}
              ..addAll(
                e.value,
              )
              ..['id'] = e.key;
            return fromJson(
              map,
            );
          },
        ).toList();
      },
    );
  }
}
