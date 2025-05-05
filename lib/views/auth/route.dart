import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/views/auth/bloc.dart';
import 'package:note_maker/views/auth/repository.dart';
import 'package:note_maker/views/auth/state.dart';
import 'package:note_maker/views/auth/view.dart';

class AuthPageRoute extends GoRouteData {
  AuthPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final redirectTo = switch (state.uri.queryParameters) {
      {
        'redirect-to': final String redirectTo,
      } =>
        redirectTo,
      _ => '/',
    };
    return RepositoryProvider(
      create: (context) {
        return AuthPageRepository();
      },
      child: BlocProvider(
        create: (context) {
          final authRepo = context.read<AuthPageRepository>();
          return AuthPageBloc(
            redirectTo: redirectTo,
            initialState: LoginFormState(),
            authRepo: authRepo,
          );
        },
        child: AuthPage(),
      ),
    );
  }
}
