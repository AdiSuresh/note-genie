import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/views/auth/bloc.dart';
import 'package:note_maker/views/auth/repository.dart';
import 'package:note_maker/views/auth/view.dart';
import 'package:note_maker/views/home/route/route.dart';

class AuthPageRoute extends GoRouteData with $AuthPageRoute {
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
            authRepo: authRepo,
          );
        },
        child: AuthPage(),
      ),
    );
  }
}
