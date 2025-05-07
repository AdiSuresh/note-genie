sealed class AuthResponse {
  const AuthResponse();
}

sealed class AuthSuccess extends AuthResponse {
  const AuthSuccess();
}

sealed class AuthFailure<R extends Enum> implements AuthResponse {
  final R reason;

  const AuthFailure(
    this.reason,
  );
}

sealed class LoginResponse extends AuthResponse {}

final class LoginSuccess extends LoginResponse {}

enum LoginFailureReason {
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

  const LoginFailureReason(
    this.message,
  );
}

final class LoginFailure extends AuthFailure<LoginFailureReason>
    implements LoginResponse {
  const LoginFailure([
    super.reason = LoginFailureReason.other,
  ]);
}

sealed class RegistrationResponse extends AuthResponse {
  const RegistrationResponse();
}

final class RegistrationSuccess extends RegistrationResponse {
  const RegistrationSuccess();
}

enum RegistrationFailureReason {
  alreadyExists(
    'This email is already in use',
  ),
  noInternet(
    'Please check your internet connection',
  ),
  other(
    'Something went wrong',
  );

  final String message;

  const RegistrationFailureReason(
    this.message,
  );
}

final class RegistrationFailure extends AuthFailure<RegistrationFailureReason>
    implements RegistrationResponse {
  const RegistrationFailure([
    super.reason = RegistrationFailureReason.other,
  ]);
}
