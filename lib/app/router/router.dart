import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/app_navigator_observer.dart';
import 'package:note_maker/app/router/blocs/extra_variable/bloc.dart';
import 'package:note_maker/app/router/blocs/navigation/bloc.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/utils/extensions/type.dart';
import 'package:note_maker/views/edit_note/bloc.dart';
import 'package:note_maker/views/edit_note/repository.dart';
import 'package:note_maker/views/edit_note/state/state.dart';
import 'package:note_maker/views/home/repository.dart';
import 'package:note_maker/views/home/state/state.dart';
import 'package:note_maker/views/edit_note/view.dart';
import 'package:note_maker/views/home/bloc.dart';
import 'package:note_maker/views/home/view.dart';
import 'package:note_maker/views/note_info/bloc.dart';
import 'package:note_maker/views/note_info/state.dart';
import 'package:note_maker/views/note_info/view.dart';
import 'package:note_maker/widgets/draggable_scrollable_bloc/bloc.dart';

class AppRouter {
  const AppRouter._();

  static List<GoRoute> get _routes => [
        GoRoute(
          path: HomePage.path,
          builder: (context, state) {
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
          },
          routes: [
            GoRoute(
              path: (EditNote).asRouteName(),
              builder: (context, state) {
                final note = switch (context.extra) {
                  final NoteEntity note => note,
                  _ => NoteEntity.empty(),
                };
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) {
                        return DraggableScrollableBloc();
                      },
                    ),
                    RepositoryProvider(
                      create: (context) {
                        return EditNoteRepository();
                      },
                    ),
                    BlocProvider(
                      create: (context) {
                        return EditNoteBloc(
                          EditNoteState(
                            note: note,
                            unlinkedCollections: [],
                          ),
                          repository: context.read<EditNoteRepository>(),
                        );
                      },
                    ),
                  ],
                  child: const EditNote(),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/note-info',
          builder: (context, state) {
            final note = context.extra is Note ? context.extra : Note.empty();
            return BlocProvider(
              create: (context) {
                return NoteInfoBloc(
                  NoteInfoState(
                    note: note,
                  ),
                );
              },
              child: const NoteInfo(),
            );
          },
        ),
      ];

  static String get path {
    return router.routeInformationProvider.value.uri.path;
  }

  static final routeObserver = AppNavigatorObserver();

  static final router = GoRouter(
    initialLocation: HomePage.path,
    routes: _routes,
    observers: [
      routeObserver,
    ],
  );

  static const _instance = AppRouter._();

  factory AppRouter() {
    return _instance;
  }
}
