import 'dart:async';

import 'package:path/path.dart' as path;
import 'package:note_maker/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';

class ObjectBoxDB {
  static final _singleton = ObjectBoxDB._();

  Completer<Store>? _completer;

  ObjectBoxDB._();

  factory ObjectBoxDB() {
    return _singleton;
  }

  Future<Store> get store async {
    _completer ??= Completer<Store>()
      ..complete(
        _init(),
      );
    return _completer!.future;
  }

  static Future<Store> _init() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return Store(
      getObjectBoxModel(),
      directory: path.join(
        docsDir.path,
        'database',
      ),
    );
  }
}
