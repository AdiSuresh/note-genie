import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/router/blocs/navigation/bloc.dart';
import 'package:note_maker/views/chat/route.dart';
import 'package:note_maker/views/edit_note/route.dart';
import 'package:note_maker/views/home/bloc.dart';
import 'package:note_maker/views/home/repository.dart';
import 'package:note_maker/views/home/state/state.dart';
import 'package:note_maker/views/home/view.dart';

part 'route.g.dart';

@TypedGoRoute<HomeRoute>(
  path: HomePage.path,
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<EditNoteRoute>(
      path: 'edit-note',
    ),
    TypedGoRoute<ChatRoute>(
      path: 'chat',
    ),
  ],
)
class HomeRoute extends GoRouteData {
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
