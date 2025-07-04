import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:note_maker/models/user/model.dart';

class SessionManager {
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user';

  static final SessionManager _instance = SessionManager._();

  static const _storage = FlutterSecureStorage();

  factory SessionManager() => _instance;

  SessionManager._();

  Future<void> saveUser(
    User user,
  ) async {
    await _storage.write(
      key: _userKey,
      value: json.encode(
        user.toJson(),
      ),
    );
  }

  Future<User?> getUser() async {
    final data = await _storage.read(
      key: _userKey,
    );
    try {
      final decoded = json.decode(
        data!,
      );
      final user = User.fromJson(
        decoded,
      );
      return user;
    } catch (e) {
      // ignored
    }
    return null;
  }

  Future<void> deleteUser() async {
    await _storage.delete(
      key: _userKey,
    );
  }

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

  Future<void> logout() async {
    await Future.wait(
      [
        deleteAccessToken(),
        deleteUser(),
      ],
    );
  }
}
