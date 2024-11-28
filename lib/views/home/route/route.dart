import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/router/blocs/navigation/bloc.dart';
import 'package:note_maker/utils/ui_utils.dart';
import 'package:note_maker/views/edit_note/route/route.dart';
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
  HomeBloc? _bloc;

  HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final provider = MultiBlocProvider(
      providers: [
        RepositoryProvider(
          create: (context) {
            return HomeRepository();
          },
        ),
        BlocProvider(
          create: (context) {
            final result = HomeBloc(
              const IdleState(
                notes: [],
                noteCollections: [],
              ),
              context.read<NavigationBloc>(),
              repository: context.read<HomeRepository>(),
              path: HomePage.path,
            );
            _bloc = result;
            return result;
          },
        ),
      ],
      child: const HomePage(),
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        switch (_bloc) {
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
        final shouldExit = await UiUtils.showProceedDialog(
          title: 'Exit app?',
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
        if (shouldExit case true when context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: provider,
    );
  }
}
