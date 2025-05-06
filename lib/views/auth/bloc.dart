import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/views/auth/event.dart';
import 'package:note_maker/views/auth/repository.dart';
import 'package:note_maker/views/auth/state/state.dart';

class AuthPageBloc extends Bloc<AuthPageEvent, AuthPageState> {
  final String redirectTo;
  final AuthPageRepository authRepo;

  AuthPageBloc({
    AuthPageState? initialState,
    this.redirectTo = '/',
    required this.authRepo,
  }) : super(
          initialState ?? LoginFormState(),
        ) {
    on<SubmitFormEvent>(
      (event, emit) {
        final state = switch (this.state) {
          final AuthFormState state => state,
          _ => null,
        };
        if (state case null) {
          return;
        }
        final nextEvent = switch (state) {
          LoginFormState() => AttemptLoginEvent.new,
          RegisterFormState() => AttemptRegistrationEvent.new,
        }(
          email: event.email,
          password: event.password,
        );
        add(
          nextEvent,
        );
      },
    );
    on<AttemptLoginEvent>(
      (event, emit) async {
        final state = switch (this.state) {
          final LoginFormState state => state,
          _ => null,
        };
        if (state case null) {
          return;
        }
        emit(
          AuthenticatingState(
            previousState: state,
          ),
        );
        await Future.delayed(
          const Duration(
            milliseconds: 500,
          ),
        );
        final response = await authRepo.login(
          email: event.email,
          password: event.password,
        );
        emit(
          LoginAttemptedState(
            previousState: state,
            response: response,
          ),
        );
      },
    );
    on<AttemptRegistrationEvent>(
      (event, emit) async {
        final state = switch (this.state) {
          final RegisterFormState state => state,
          _ => null,
        };
        if (state case null) {
          return;
        }
        emit(
          AuthenticatingState(
            previousState: state,
          ),
        );
        await Future.delayed(
          const Duration(
            milliseconds: 500,
          ),
        );
        final response = await authRepo.register(
          email: event.email,
          password: event.password,
        );
        emit(
          RegistrationAttemptedState(
            previousState: state,
            response: response,
          ),
        );
      },
    );
    on<ToggleFormEvent>(
      (event, emit) {
        final nextState = switch (state.formState) {
          LoginFormState() => RegisterFormState(),
          RegisterFormState() => LoginFormState(),
        };
        emit(
          nextState,
        );
      },
    );
    on<ResetStateEvent>(
      (event, emit) {
        emit(
          state.formState,
        );
      },
    );
  }
}
