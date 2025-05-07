import 'package:note_maker/models/auth/auth_response.dart';

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

sealed class NonIdleState<S extends AuthFormState> extends AuthPageState {
  final S previousState;

  const NonIdleState({
    required this.previousState,
  });
}

final class AuthenticatingState extends NonIdleState {
  const AuthenticatingState({
    required super.previousState,
  });
}

sealed class AuthAttemptedState<R extends AuthResponse, S extends AuthFormState>
    extends NonIdleState<S> {
  final R response;

  const AuthAttemptedState({
    required super.previousState,
    required this.response,
  });
}

final class LoginAttemptedState
    extends AuthAttemptedState<LoginResponse, LoginFormState> {
  const LoginAttemptedState({
    required super.previousState,
    required super.response,
  });
}

final class RegistrationAttemptedState
    extends AuthAttemptedState<RegistrationResponse, RegisterFormState> {
  const RegistrationAttemptedState({
    required super.previousState,
    required super.response,
  });
}

extension AuthPageStateExtension on AuthPageState {
  AuthFormState get formState {
    return switch (this) {
      final AuthFormState state => state,
      final NonIdleState state => state.previousState,
    };
  }
}
