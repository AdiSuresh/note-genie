import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/views/edit_note/event.dart';
import 'package:note_maker/views/edit_note/state/state.dart';

class EditNoteBloc extends Bloc<EditNoteEvent, EditNoteState> {
  EditNoteBloc(
    super.initialState,
  ) {
    on<UpdateNoteEvent>(
      (event, emit) {
        emit(
          state.copyWith(
            note: event.note,
          ),
        );
      },
    );
    on<UpdateNoteCollectionsEvent>(
      (event, emit) {
        emit(
          state.copyWith(
            noteCollections: event.noteCollections,
          ),
        );
      },
    );
  }
}
