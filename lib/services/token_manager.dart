import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const String _tokenKey = 'access_token';

  static final TokenManager _instance = TokenManager._();

  static const _storage = FlutterSecureStorage();

  factory TokenManager() => _instance;

  TokenManager._();

  Future<void> saveAccessToken(
    String token,
  ) async {
    await _storage.write(
      key: _tokenKey,
      value: token,
    );
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(
      key: _tokenKey,
    );
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(
      key: _tokenKey,
    );
  }

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
