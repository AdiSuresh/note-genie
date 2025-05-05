sealed class AuthResponse {
  const AuthResponse();
}

sealed class LoginResponse extends AuthResponse {
  const LoginResponse();
}

final class LoginSuccess extends LoginResponse {
  const LoginSuccess();
}

enum LoginFailureType {
  unknownAccount(
    'Invalid credentials',
  ),
  noInternet(
    'Please check your internet connection',
  ),
  other(
    'Something went wrong',
  );

  final String message;

  const LoginFailureType(
    this.message,
  );
}

final class LoginFailure extends LoginResponse {
  final LoginFailureType type;

  const LoginFailure([
    this.type = LoginFailureType.other,
  ]);
}

sealed class RegistrationResponse extends AuthResponse {
  const RegistrationResponse();
}

final class RegistrationSuccess extends RegistrationResponse {
  const RegistrationSuccess();
}

final class RegistrationFailure extends RegistrationResponse {
  final String message;

  const RegistrationFailure(
    this.message,
  );
}
