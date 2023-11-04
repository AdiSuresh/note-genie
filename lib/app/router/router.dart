import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'extra_variable/bloc.dart';
import '../../models/note_collection/note_collection.dart';
import '../../views/edit_note_collection/bloc.dart';
import '../../views/edit_note_collection/state.dart';
import '../../views/edit_note_collection/view.dart';
import '../../views/home/state.dart';
import '../../views/edit_note/view.dart';
import '../../views/home/bloc.dart';
import '../../views/home/view.dart';

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
            return const EditNote();
          },
        ),
        GoRoute(
          path: '/edit-note-collection',
          builder: (context, state) {
            final NoteCollection? extra = context.extra;
            return BlocProvider(
              create: (context) {
                return EditNoteCollectionBloc(
                  EditNoteCollectionState(
                    collection: extra,
                  ),
                );
              },
              child: const EditNoteCollection(),
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
