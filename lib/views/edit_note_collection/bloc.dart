import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/models/note_collection/dao.dart';
import 'package:note_maker/views/edit_note_collection/event.dart';
import 'package:note_maker/views/edit_note_collection/state.dart';

class EditNoteCollectionBloc
    extends Bloc<EditNoteCollectionEvent, EditNoteCollectionState> {
  static final noteCollectionDao = NoteCollectionDao();

  EditNoteCollectionBloc(
    super.initialState,
  );
}
