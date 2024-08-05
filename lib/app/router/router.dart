import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/router/extra_variable/bloc.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/views/edit_note/bloc.dart';
import 'package:note_maker/views/edit_note/state.dart';
import 'package:note_maker/views/home/state/state.dart';
import 'package:note_maker/views/edit_note/view.dart';
import 'package:note_maker/views/home/bloc.dart';
import 'package:note_maker/views/home/view.dart';
import 'package:note_maker/views/note_info/bloc.dart';
import 'package:note_maker/views/note_info/state.dart';
import 'package:note_maker/views/note_info/view.dart';

class AppRouter {
  AppRouter._();

  static List<GoRoute> get routes => [
        GoRoute(
          path: '/',
          builder: (context, state) {
            return BlocProvider(
              create: (context) {
                return HomeBloc(
                  const HomeState(
                    notes: [],
                    noteCollections: [],
                  ),
                );
              },
              child: const HomePage(),
            );
          },
        ),
        GoRoute(
          path: '/edit-note',
          builder: (context, state) {
            final note = context.extra is Note ? context.extra : Note.empty();
            return BlocProvider(
              create: (context) {
                return EditNoteBloc(
                  EditNoteState(
                    note: note,
                  ),
                );
              },
              child: const EditNote(),
            );
          },
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

  static final router = GoRouter(
    initialLocation: '/',
    routes: routes,
  );

  static final _instance = AppRouter._();

  factory AppRouter() {
    return _instance;
  }
}
