import 'dart:convert';
import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:note_maker/services/env_var_loader.dart';
import 'package:note_maker/utils/extensions/base_response.dart';
import 'package:note_maker/utils/extensions/jwt.dart';
import 'package:note_maker/models/auth/auth_response.dart';

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

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final url = _loginUrl;
    const unknownError = LoginFailure();
    if (url == null) {
      return unknownError;
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
    } on SocketException {
      return LoginFailure(
        LoginFailureReason.noInternet,
      );
    } catch (e) {
      return unknownError;
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
            return LoginSuccess();
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
                'detail': 'invalid_credentials',
              }
              when response.statusCode ~/ 100 == 4:
            return LoginFailure(
              LoginFailureReason.unknownAccount,
            );
          case _:
        }
      } catch (e) {
        // ignored
      }
    }
    return unknownError;
  }

  Future<RegistrationResponse> register({
    required String email,
    required String password,
  }) async {
    final url = _registrationUrl;
    const unknownError = RegistrationFailure();
    if (url == null) {
      return unknownError;
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
    } on SocketException {
      return RegistrationFailure(
        RegistrationFailureReason.noInternet,
      );
    } catch (e) {
      return unknownError;
    }
    if (response.ok) {
      try {
        final decoded = json.decode(
          response.body,
        );
        switch (decoded) {
          case {
              'message': String(),
            }:
            return RegistrationSuccess();
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
                'detail': 'already_exists',
              }
              when response.statusCode ~/ 100 == 4:
            return RegistrationFailure(
              RegistrationFailureReason.alreadyExists,
            );
          case _:
        }
      } catch (e) {
        // ignored
      }
    }
    return unknownError;
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
