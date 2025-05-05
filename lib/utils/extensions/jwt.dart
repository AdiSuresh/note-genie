import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

extension IsExpiredExtension on JWT {
  bool get isExpired {
    switch (payload) {
      case {
          'exp': final int exp,
        }:
        return DateTime.now().isAfter(
          DateTime.fromMillisecondsSinceEpoch(
            exp * 1000,
          ),
        );
      case _:
    }
    return false;
  }
}
