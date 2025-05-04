import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/views/auth/event.dart';
import 'package:note_maker/views/auth/state.dart';

class AuthPageBloc extends Bloc<AuthPageEvent, AuthPageState> {
  AuthPageBloc({
    AuthPageState? initialState,
  }) : super(
          initialState ?? LoginState(),
        ) {
    on<LoginEvent>(
      (event, emit) {
        final state = switch (this.state) {
          final LoginState state => state,
          _ => null,
        };
        if (state case null) {
          return;
        }
      },
    );
    on<RegisterEvent>(
      (event, emit) {
        final state = switch (this.state) {
          final RegisterState state => state,
          _ => null,
        };
        if (state case null) {
          return;
        }
      },
    );
  }
}
