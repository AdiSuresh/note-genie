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

final class AttemptSignInEvent extends AuthenticateEvent {
  const AttemptSignInEvent({
    required super.email,
    required super.password,
  });
}

final class AttemptSignUpEvent extends AuthenticateEvent {
  const AttemptSignUpEvent({
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

final class ToggleFormEvent extends AuthPageEvent {
  const ToggleFormEvent();
}

final class ResetStateEvent extends AuthPageEvent {
  const ResetStateEvent();
}
