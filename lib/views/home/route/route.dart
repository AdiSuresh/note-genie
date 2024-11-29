import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/router/blocs/navigation/bloc.dart';
import 'package:note_maker/utils/ui_utils.dart';
import 'package:note_maker/views/edit_note/route.dart';
import 'package:note_maker/views/home/bloc.dart';
import 'package:note_maker/views/home/event.dart';
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
  ],
)
class HomeRoute extends GoRouteData {
  HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final child = Builder(
      builder: (context) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) {
              return;
            }
            switch (context.read<HomeBloc>()) {
              case HomeBloc(
                  state: SearchState(),
                  :final add,
                  isClosed: false,
                ):
                add(
                  ToggleSearchEvent(),
                );
                return;
              case _:
            }
            final exit = await UiUtils.showProceedDialog(
              title: 'App Exit',
              message: 'Would you like to exit the app?',
              context: context,
              onYes: () {
                context.pop(
                  true,
                );
              },
              onNo: () {
                context.pop(
                  false,
                );
              },
            );
            if (exit case true when context.mounted) {
              SystemNavigator.pop();
            }
          },
          child: const HomePage(),
        );
      },
    );
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
      child: child,
    );
  }
}
