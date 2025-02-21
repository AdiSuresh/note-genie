import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvVarData {
  static final _instance = EnvVarData._();

  EnvVarData._();

  factory EnvVarData() {
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
