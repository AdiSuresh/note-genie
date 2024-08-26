import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/views/edit_note/event.dart';
import 'package:note_maker/views/edit_note/state.dart';

class EditNoteBloc extends Bloc<EditNoteEvent, EditNoteState> {
  EditNoteBloc(
    super.initialState,
  ) {
    on<UpdateTitleEvent>(
      (event, emit) {
        /* emit(
          EditNoteState(
            note: state.note.copyWith(
              title: event.title,
            ),
          ),
        ); */
      },
    );
    on<UpdateNoteEvent>(
      (event, emit) {
        emit(
          EditNoteState(
            note: event.note,
          ),
        );
      },
    );
  }
}
