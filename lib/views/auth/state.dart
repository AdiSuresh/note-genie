sealed class AuthPageState {
  const AuthPageState();
}

sealed class AuthFormState extends AuthPageState {
  const AuthFormState();
}

final class LoginFormState extends AuthFormState {
  const LoginFormState();
}

final class RegisterFormState extends AuthFormState {
  const RegisterFormState();
}

sealed class NonIdleState extends AuthPageState {
  final AuthFormState previousState;

  const NonIdleState({
    required this.previousState,
  });
}

final class AuthenticatingState extends NonIdleState {
  const AuthenticatingState({
    required super.previousState,
  });
}

sealed class AuthAttemptedState extends NonIdleState {
  const AuthAttemptedState({
    required super.previousState,
  });
}

final class AuthSuccessState extends AuthAttemptedState {
  const AuthSuccessState({
    required super.previousState,
  });
}

final class AuthFailureState extends AuthAttemptedState {
  const AuthFailureState({
    required super.previousState,
  });
}
