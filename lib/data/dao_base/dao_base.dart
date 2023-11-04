import 'package:note_maker/data/local_database.dart';
import 'package:sembast/sembast.dart';

class DaoBase {
  final StoreRef<int, Map<String, Object?>> _store;

  Future<Database> get db async => await LocalDatabase.instance.database;

  StoreRef<int, Map<String, Object?>> get store => _store;

  DaoBase(
    String storeName,
  ) : _store = intMapStoreFactory.store(
          storeName,
        );
}
