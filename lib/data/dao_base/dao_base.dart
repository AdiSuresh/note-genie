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

  Future<int> add(
    T value,
  ) async {
    return store.add(
      await db,
      value.toJson(),
    );
  }

  Future<T?> update(
    T value,
  ) async {
    switch (value.id) {
      case final int id:
        return store
            .record(
              id,
            )
            .update(
              await db,
              value.toJson(),
            )
            .then(
          (value) {
            T? result;
            try {
              result = fromJson(
                value!,
              );
            } catch (e) {
              // ignored
            }
            return result;
          },
        );
      case _:
        return null;
    }
  }

  Future<int?> delete(
    T value,
  ) async {
    switch (value.id) {
      case final int id:
        return store
            .record(
              id,
            )
            .delete(
              await db,
            );
      case _:
        return null;
    }
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
