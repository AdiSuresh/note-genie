import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class LocalDatabase {
  static final LocalDatabase _singleton = LocalDatabase._();

  static LocalDatabase get instance => _singleton;

  Completer<Database>? _openDbCompleter;

  LocalDatabase._();

  factory LocalDatabase() {
    return _singleton;
  }

  Future<Database> get database async {
    if (_openDbCompleter == null) {
      _openDbCompleter = Completer();
      await _openDatabase();
    }
    return _openDbCompleter!.future;
  }

  Future<Database?> _openDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(
      dir.path,
      'main.db',
    );
    final database = await databaseFactoryIo.openDatabase(
      dbPath,
    );
    _openDbCompleter?.complete(
      database,
    );
    return _openDbCompleter?.future;
  }
}
