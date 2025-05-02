import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/models/future_data/model.dart';
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
          SaveNoteLocallyEvent(
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
          SaveNoteLocallyEvent(
            note: note,
          ),
        );
      },
    );
    on<SaveNoteLocallyEvent>(
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
        if (event.saveRemotely) {
          add(
            SaveNoteRemotelyEvent(
              note: note,
            ),
          );
        }
      },
    );
    on<SaveNoteRemotelyEvent>(
      (event, emit) async {
        switch (state.remoteId) {
          case AsyncData(
              data: String(),
            ):
            logger.i('/notes PUT method');
            try {
              await state.remoteId.future;
            } catch (e) {
              // ignored
            }
            final response = await repository.saveNoteRemote(
              event.note,
            );
            logger.i(response);
          case AsyncData(
              data: null,
              state: AsyncDataState.loaded,
            ):
            logger.i('/notes POST method');
            emit(
              state.copyWith(
                remoteId: state.remoteId.copyWith(
                  state: AsyncDataState.loading,
                ),
              ),
            );
            try {
              final future = repository.createNoteRemote(
                state.note,
              );
              emit(
                state.copyWith(
                  remoteId: state.remoteId.copyWith(
                    future: future,
                  ),
                ),
              );
              final id = await future;
              if (id case String()) {
                final note = state.note.copyWith(
                  remoteId: id,
                );
                emit(
                  state.copyWith(
                    note: note,
                    remoteId: AsyncData.initial(
                      id,
                    ),
                  ),
                );
                add(
                  SaveNoteLocallyEvent(
                    note: note,
                    saveRemotely: false,
                  ),
                );
              } else {
                throw Exception('Request failed');
              }
            } catch (e) {
              logger.i('error while creating note: $e');
              emit(
                state.copyWith(
                  remoteId: AsyncData.initial(
                    null,
                  ),
                ),
              );
            }
          case _:
            logger.i('other condition');
            logger.i(state.remoteId.data);
            logger.i(state.remoteId.state);
        }
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
    on<LeavePageEvent>(
      (event, emit) async {
        await repository.updateNoteEmbeddings(
          state.note,
        );
      },
    );
  }
}
