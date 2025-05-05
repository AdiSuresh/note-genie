import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:note_maker/services/env_var_loader.dart';
import 'package:note_maker/utils/extensions/base_response.dart';
import 'package:note_maker/utils/extensions/jwt.dart';

class AuthPageRepository {
  static const resultOnError = (
    false,
    'Something went wrong',
  );

  final _storage = FlutterSecureStorage();
  final _env = EnvVarLoader();

  Uri? get _loginUrl {
    return _env.backendUrl?.replace(
      path: '/login',
    );
  }

  Uri? get _registrationUrl {
    return _env.backendUrl?.replace(
      path: '/register',
    );
  }

  Future<(bool, String)> login({
    required String email,
    required String password,
  }) async {
    final url = _loginUrl;
    if (url == null) {
      return resultOnError;
    }
    http.Response? response;
    try {
      response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'email': email,
            'password': password,
          },
        ),
      );
      print('response: ${response.reasonPhrase}');
    } catch (e) {
      return resultOnError;
    }
    if (response.ok) {
      try {
        final decoded = json.decode(
          response.body,
        );
        switch (decoded) {
          case {
              'access_token': final String token,
              'token_type': String(),
            }:
            await _storage.write(
              key: 'access_token',
              value: token,
            );
            return (
              true,
              'Logged in successfully',
            );
          case _:
        }
      } catch (e) {
        // ignored
      }
    } else {
      try {
        final decoded = json.decode(
          response.body,
        );
        switch (decoded) {
          case {
              'detail': final String detail,
            }:
            return (
              false,
              detail,
            );
          case _:
        }
      } catch (e) {
        // ignored
      }
    }
    return resultOnError;
  }

  Future<(bool, String)> register({
    required String email,
    required String password,
  }) async {
    final url = _registrationUrl;
    if (url == null) {
      return resultOnError;
    }
    http.Response? response;
    try {
      response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'email': email,
            'password': password,
          },
        ),
      );
    } catch (e) {
      return resultOnError;
    }
    if (response.ok) {
      try {
        final decoded = json.decode(
          response.body,
        );
        switch (decoded) {
          case {
              'message': final String message,
            }:
            return (
              true,
              message,
            );
          case _:
        }
      } catch (e) {
        // ignored
      }
    } else {
      try {
        final decoded = json.decode(
          response.body,
        );
        switch (decoded) {
          case {
              'detail': final String detail,
            }:
            return (
              false,
              detail,
            );
          case _:
        }
      } catch (e) {
        // ignored
      }
    }
    return resultOnError;
  }

  Future<bool> get isLoggedIn async {
    final token = await _storage.read(
      key: 'access_token',
    );
    switch (token) {
      case String():
        try {
          final jwt = JWT.decode(
            token,
          );
          if (!jwt.isExpired) {
            return true;
          }
        } catch (e) {
          // ignored
        }
      case _:
    }
    await logout();
    return false;
  }

  Future<void> logout() async {
    await _storage.delete(
      key: 'access_token',
    );
  }
}
