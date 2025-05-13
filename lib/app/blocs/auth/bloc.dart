import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/services/token_manager.dart';
import 'package:note_maker/app/blocs/auth/event.dart';
import 'package:note_maker/app/blocs/auth/state.dart';

final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final _tokenManager = TokenManager();

  AuthBloc([
    super.initialState = const UnauthenticatedState(),
  ]) {
    on<SignInUserEvent>(
      (event, emit) {
        emit(
          AuthenticatedState(
            user: event.user,
          ),
        );
      },
    );
    on<SignOutUserEvent>(
      (event, emit) async {
        await _tokenManager.deleteAccessToken();
        emit(
          const UnauthenticatedState(),
        );
      },
    );
  }
}
