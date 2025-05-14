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
          AuthenticatedState(
            user: event.user,
          ),
        );
        await _sessionManager.saveUser(
          event.user,
        );
      },
    );
    on<AttemptSignInEvent>(
      (event, emit) async {
        final user = await _sessionManager.getUser();
        switch (user) {
          case User():
            emit(
              AuthenticatedState(
                user: user,
              ),
            );
          case _:
        }
      },
    );
    on<SignOutUserEvent>(
      (event, emit) async {
        await _sessionManager.deleteAccessToken();
        emit(
          const UnauthenticatedState(),
        );
      },
    );
  }
}
