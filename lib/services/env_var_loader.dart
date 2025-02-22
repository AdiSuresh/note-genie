import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvVarLoader {
  static final _instance = EnvVarLoader._();

  EnvVarLoader._();

  factory EnvVarLoader() {
    return _instance;
  }

  Uri? get backendUrl {
    return switch (dotenv.env['BACKEND_URL']) {
      final String url => Uri.parse(
          url,
        ),
      _ => null,
    };
  }
}
