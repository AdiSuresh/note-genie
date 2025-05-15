import 'package:note_maker/models/user/model.dart';

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

sealed class SignInResponse extends AuthResponse {
  const SignInResponse();
}

final class SignInSuccess extends SignInResponse {
  final User user;

  const SignInSuccess({
    required this.user,
  });
}

enum SignInFailureReason {
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

  const SignInFailureReason(
    this.message,
  );
}

final class SignInFailure extends AuthFailure<SignInFailureReason>
    implements SignInResponse {
  const SignInFailure([
    super.reason = SignInFailureReason.other,
  ]);
}

sealed class SignUpResponse extends AuthResponse {
  const SignUpResponse();
}

final class SignUpSuccess extends SignUpResponse {
  const SignUpSuccess();
}

enum SignUpFailureReason {
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

  const SignUpFailureReason(
    this.message,
  );
}

final class SignUpFailure extends AuthFailure<SignUpFailureReason>
    implements SignUpResponse {
  const SignUpFailure([
    super.reason = SignUpFailureReason.other,
  ]);
}
