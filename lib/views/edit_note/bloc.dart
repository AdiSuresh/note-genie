import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/models/note/extensions.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/views/edit_note/event.dart';
import 'package:note_maker/views/edit_note/repository.dart';
import 'package:note_maker/views/edit_note/state/state.dart';

class EditNoteBloc extends Bloc<EditNoteEvent, EditNoteState> {
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
        final note = await repository.saveNote(
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
      (event, emit) {
        state.note.addToCollection(
          event.collection,
        );
        emit(
          state.copyWith(),
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
  }
}
