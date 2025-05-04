sealed class AuthPageEvent {}

sealed class AuthenticateEvent extends AuthPageEvent {
  final String email;
  final String password;

  AuthenticateEvent({
    required this.email,
    required this.password,
  });
}

final class LoginEvent extends AuthenticateEvent {
  LoginEvent({
    required super.email,
    required super.password,
  });
}

final class RegisterEvent extends AuthenticateEvent {
  RegisterEvent({
    required super.email,
    required super.password,
  });
}
