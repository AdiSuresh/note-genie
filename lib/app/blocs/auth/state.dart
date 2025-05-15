import 'package:note_maker/models/user/model.dart';

sealed class AuthState {
  const AuthState();
}

final class AuthenticatedState extends AuthState {
  final User user;

  const AuthenticatedState({
    required this.user,
  });
}

final class AuthenticatingState extends AuthState {
  const AuthenticatingState();
}

final class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}
