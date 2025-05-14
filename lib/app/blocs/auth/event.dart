import 'package:note_maker/models/user/model.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class AttemptSignInEvent extends AuthEvent {
  const AttemptSignInEvent();
}

final class SignInUserEvent extends AuthEvent {
  final User user;

  const SignInUserEvent({
    required this.user,
  });
}

final class SignOutUserEvent extends AuthEvent {
  const SignOutUserEvent();
}
