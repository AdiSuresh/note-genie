import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/models/user/model.dart';
import 'package:note_maker/services/session_manager.dart';
import 'package:note_maker/app/blocs/auth/event.dart';
import 'package:note_maker/app/blocs/auth/state.dart';

final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final _sessionManager = SessionManager();

  AuthBloc([
    super.initialState = const UnauthenticatedState(),
  ]) {
    on<SignInUserEvent>(
      (event, emit) async {
        emit(
          const AuthenticatingState(),
        );
        await _sessionManager.saveUser(
          event.user,
        );
        emit(
          AuthenticatedState(
            user: event.user,
          ),
        );
      },
    );
    on<AttemptSignInEvent>(
      (event, emit) async {
        emit(
          const AuthenticatingState(),
        );
        final user = await _sessionManager.getUser();
        final nextState = switch (user) {
          final User user => AuthenticatedState(
              user: user,
            ),
          _ => const UnauthenticatedState(),
        };
        emit(
          nextState,
        );
      },
    );
    on<SignOutUserEvent>(
      (event, emit) async {
        emit(
          const AuthenticatingState(),
        );
        await _sessionManager.logout();
        emit(
          const UnauthenticatedState(),
        );
      },
    );
  }
}
