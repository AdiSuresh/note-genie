import 'dart:convert';
import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:note_maker/core/constants/http.dart';
import 'package:note_maker/models/user/model.dart';
import 'package:note_maker/services/env_var_loader.dart';
import 'package:note_maker/services/session_manager.dart';
import 'package:note_maker/utils/extensions/base_response.dart';
import 'package:note_maker/utils/extensions/jwt.dart';
import 'package:note_maker/models/auth/auth_response.dart';

class AuthPageRepository {
  static const resultOnError = (
    false,
    'Something went wrong',
  );

  final _env = EnvVarLoader();
  final _sessionManager = SessionManager();

  Uri? get _signInUrl {
    return _env.backendUrl?.replace(
      path: '/sign-in',
    );
  }

  Uri? get _registrationUrl {
    return _env.backendUrl?.replace(
      path: '/sign-up',
    );
  }

  Future<SignInResponse> signIn({
    required String email,
    required String password,
  }) async {
    final url = _signInUrl;
    const unknownError = SignInFailure();
    if (url == null) {
      return unknownError;
    }
    http.Response? response;
    try {
      response = await http.post(
        url,
        headers: HttpConstants.baseHeaders,
        body: json.encode(
          {
            'email': email,
            'password': password,
          },
        ),
      );
    } on SocketException {
      return SignInFailure(
        SignInFailureReason.noInternet,
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
            await _sessionManager.saveAccessToken(
              token,
            );
            return SignInSuccess(
              user: User(
                email: email,
              ),
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
                'detail': 'invalid_credentials',
              }
              when response.statusCode ~/ 100 == 4:
            return SignInFailure(
              SignInFailureReason.unknownAccount,
            );
          case _:
        }
      } catch (e) {
        // ignored
      }
    }
    return unknownError;
  }

  Future<SignUpResponse> signUp({
    required String email,
    required String password,
  }) async {
    final url = _registrationUrl;
    const unknownError = SignUpFailure();
    if (url == null) {
      return unknownError;
    }
    http.Response? response;
    try {
      response = await http.post(
        url,
        headers: HttpConstants.baseHeaders,
        body: json.encode(
          {
            'email': email,
            'password': password,
          },
        ),
      );
    } on SocketException {
      return SignUpFailure(
        SignUpFailureReason.noInternet,
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
            return SignUpSuccess();
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
            return SignUpFailure(
              SignUpFailureReason.alreadyExists,
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
    final token = await _sessionManager.getAccessToken();
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
    await _sessionManager.deleteAccessToken();
  }
}
