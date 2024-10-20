import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/models/note/extensions.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/views/edit_note/event.dart';
import 'package:note_maker/views/edit_note/repository.dart';
import 'package:note_maker/views/edit_note/state/state.dart';

class EditNoteBloc extends Bloc<EditNoteEvent, EditNoteState> {
  @protected
  final logger = AppLogger(
    EditNoteBloc,
  );

  @protected
  final EditNoteRepository repository;

  EditNoteBloc(
    super.initialState, {
    required this.repository,
  }) {
    on<UpdateTitleEvent>(
      (event, emit) {
        emit(
          state.copyWith(
            noteStatus: EditNoteStatus.saving,
          ),
        );
        final title = switch (event.title.trim()) {
          '' => 'Untitled',
          final s => s,
        };
        final note = state.note.copyWith(
          title: title,
        );
        add(
          SaveNoteEvent(
            note: note,
          ),
        );
      },
    );
    on<UpdateContentEvent>(
      (event, emit) {
        final content = jsonEncode(
          event.document.toDelta().toJson(),
        );
        final note = state.note.copyWith(
          content: content,
        );
        add(
          SaveNoteEvent(
            note: note,
          ),
        );
      },
    );
    on<SaveNoteEvent>(
      (event, emit) async {
        final note = await repository.putNote(
          event.note,
        );
        emit(
          state.copyWith(
            noteStatus: EditNoteStatus.saved,
            note: note,
          ),
        );
      },
    );
    on<AddToCollectionEvent>(
      (event, emit) async {
        state.note.addToCollection(
          event.collection,
        );
        final unlinkedCollections = await repository.getUnlinkedCollections(
          state.note.collections,
        );
        emit(
          state.copyWith(
            unlinkedCollections: unlinkedCollections,
          ),
        );
      },
    );
    on<RemoveFromCollectionEvent>(
      (event, emit) {
        state.note.removeFromCollection(
          event.collectionId,
        );
        emit(
          state.copyWith(),
        );
      },
    );
    on<ViewCollectionsEvent>(
      (event, emit) {
        emit(
          state.copyWith(
            viewCollections: true,
          ),
        );
      },
    );
    on<ViewUnlinkedCollectionsEvent>(
      (event, emit) async {
        final unlinkedCollections = await repository.getUnlinkedCollections(
          state.note.collections,
        );
        emit(
          state.copyWith(
            viewCollections: false,
            unlinkedCollections: unlinkedCollections,
          ),
        );
      },
    );
  }
}
