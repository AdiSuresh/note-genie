import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';

mixin SecureStorageMixin {
  @protected
  FlutterSecureStorage get storage {
    return const FlutterSecureStorage();
  }
}
