sealed class AuthPageState {
  final String? redirectTo;

  const AuthPageState({
    this.redirectTo,
  });
}

final class LoginState extends AuthPageState {
  const LoginState({
    super.redirectTo,
  });
}

final class RegisterState extends AuthPageState {
  const RegisterState({
    super.redirectTo,
  });
}
