import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/router/blocs/extra_variable/bloc.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/views/edit_note/bloc.dart';
import 'package:note_maker/views/edit_note/repository.dart';
import 'package:note_maker/views/edit_note/state/state.dart';
import 'package:note_maker/views/edit_note/view.dart';
import 'package:note_maker/widgets/draggable_scrollable_bloc/bloc.dart';

class EditNoteRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
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
  }
}
