import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/router/blocs/navigation/bloc.dart';
import 'package:note_maker/views/auth/route.dart';
import 'package:note_maker/views/chat/route.dart';
import 'package:note_maker/views/edit_note/route.dart';
import 'package:note_maker/views/home/bloc.dart';
import 'package:note_maker/views/home/repository.dart';
import 'package:note_maker/views/home/state/state.dart';
import 'package:note_maker/views/home/view.dart';
import 'package:note_maker/views/settings/route.dart';

part 'route.g.dart';

@TypedGoRoute<HomeRoute>(
  path: HomePage.path,
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<AuthPageRoute>(
      path: 'auth',
    ),
    TypedGoRoute<SettingsPageRoute>(
      path: 'settings',
    ),
    TypedGoRoute<EditNoteRoute>(
      path: 'edit-note',
    ),
    TypedGoRoute<ChatRoute>(
      path: 'chat',
      routes: [
        TypedGoRoute<ChatRoute>(
          path: ':id',
        ),
      ],
    ),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {
  HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (context) {
            return HomeRepository();
          },
        ),
        BlocProvider(
          create: (context) {
            return HomeBloc(
              const IdleState(
                notes: [],
                noteCollections: [],
              ),
              context.read<NavigationBloc>(),
              repository: context.read<HomeRepository>(),
              path: HomePage.path,
            );
          },
        ),
      ],
      child: const HomePage(),
    );
  }
}
