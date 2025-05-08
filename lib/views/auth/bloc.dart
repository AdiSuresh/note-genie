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
          initialState ?? const SignInFormState(),
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
          SignInFormState() => AttemptSignInEvent.new,
          SignUpFormState() => AttemptSignUpEvent.new,
        }(
          email: event.email,
          password: event.password,
        );
        add(
          nextEvent,
        );
      },
    );
    on<AttemptSignInEvent>(
      (event, emit) async {
        final state = switch (this.state) {
          final SignInFormState state => state,
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
        final response = await authRepo.signIn(
          email: event.email,
          password: event.password,
        );
        emit(
          SignInAttemptedState(
            previousState: state,
            response: response,
          ),
        );
      },
    );
    on<AttemptSignUpEvent>(
      (event, emit) async {
        final state = switch (this.state) {
          final SignUpFormState state => state,
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
        final response = await authRepo.signUp(
          email: event.email,
          password: event.password,
        );
        emit(
          SignUpAttemptedState(
            previousState: state,
            response: response,
          ),
        );
      },
    );
    on<ToggleFormEvent>(
      (event, emit) {
        if (state case NonIdleState()) {
          return;
        }
        final nextState = switch (state.formState) {
          SignInFormState() => const SignUpFormState(),
          SignUpFormState() => const SignInFormState(),
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
