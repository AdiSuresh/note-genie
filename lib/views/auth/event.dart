sealed class AuthPageEvent {
  const AuthPageEvent();
}

sealed class AuthenticateEvent extends AuthPageEvent {
  final String email;
  final String password;

  const AuthenticateEvent({
    required this.email,
    required this.password,
  });
}

final class AttemptLoginEvent extends AuthenticateEvent {
  const AttemptLoginEvent({
    required super.email,
    required super.password,
  });
}

final class AttemptRegistrationEvent extends AuthenticateEvent {
  const AttemptRegistrationEvent({
    required super.email,
    required super.password,
  });
}

final class SubmitFormEvent extends AuthenticateEvent {
  const SubmitFormEvent({
    required super.email,
    required super.password,
  });
}

final class SwitchAuthEvent extends AuthPageEvent {
  const SwitchAuthEvent();
}
