import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/models/note_collection/dao.dart';
import 'package:note_maker/views/note_info/event.dart';
import 'package:note_maker/views/note_info/state.dart';

class NoteInfoBloc extends Bloc<NoteInfoEvent, NoteInfoState> {
  static final noteCollectionDao = NoteCollectionDao();

  NoteInfoBloc(
    super.initialState,
  );
}
