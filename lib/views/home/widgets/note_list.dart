import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/router/blocs/extra_variable/bloc.dart';
import 'package:note_maker/utils/extensions/type.dart';
import 'package:note_maker/views/edit_note/view.dart';
import 'package:note_maker/views/home/bloc.dart';
import 'package:note_maker/views/home/event.dart';
import 'package:note_maker/views/home/state/state.dart';
import 'package:note_maker/views/home/widgets/note_list_tile.dart';
import 'package:note_maker/widgets/custom_animated_switcher.dart';
import 'package:note_maker/widgets/empty_footer.dart';
import 'package:note_maker/widgets/selection_highlight.dart';

class NoteList extends StatelessWidget {
  const NoteList({
    super.key,
  });

  Widget _buildTile(
    BuildContext context,
    int i,
  ) {
    final state = context.bloc.state;
    final note = switch (state) {
      IdleState state => state.notes[i],
      NonIdleState state => state.previousState.notes[i],
    };
    final tile = NoteListTile(
      note: note,
      onTap: () {
        switch (state) {
          case IdleState() || SearchNotesState():
            context
              ..extra = note
              ..go(
                (EditNote).asRoutePath(),
              );
          case SelectNotesState():
            context.bloc.add(
              SelectNoteEvent(
                index: i,
              ),
            );
          case _:
        }
      },
      onLongPress: switch (state) {
        IdleState() => () {
            context.bloc.add(
              SelectNoteEvent(
                index: i,
              ),
            );
          },
        _ => null,
      },
    );
    final selected = switch (state) {
      SelectNotesState(
        selected: final items,
      ) =>
        items[i],
      _ => false,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7.5,
        horizontal: 15,
      ),
      child: SelectionHighlight(
        selected: selected,
        scaleFactor: 1.0125,
        child: tile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) {
        switch ((previous, current)) {
          case (
              final IdleState prev,
              final IdleState curr,
            ):
            return prev.notes != curr.notes;
          case (
              IdleState(),
              SearchNotesState(),
            ):
            return false;
          case (
              SearchNotesState(
                searchResults: [],
              ),
              SearchNotesState(
                searchResults: [],
              ),
            ):
            return false;
          case (
              SearchNotesState(),
              SearchNotesState(),
            ):
            return true;
          case (
              IdleState() || SelectNotesState(),
              SelectNotesState(),
            ):
            return true;
          case _:
        }
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        final data = switch (state) {
          IdleState(
            :final currentCollection,
            :final notes,
          ) =>
            (
              currentCollection,
              notes,
            ),
          SearchNotesState(
            :final previousState,
            :final searchResults,
          ) =>
            (
              previousState.currentCollection,
              searchResults,
            ),
          SelectNotesState(
            :final previousState,
          ) =>
            (
              previousState.currentCollection,
              previousState.notes,
            ),
          _ => null,
        };
        final child = switch (data) {
          null => () {
              return const SizedBox();
            },
          (final currentCollection, final notes) => () {
              final key = PageStorageKey(
                switch (state) {
                  IdleState() ||
                  SelectItemsState() =>
                    currentCollection ?? 'note-list',
                  SearchState(
                    :final searchResults,
                  ) =>
                    searchResults,
                },
              );
              return switch (notes) {
                [] => const Center(
                    child: Text(
                      'No notes yet',
                    ),
                  ),
                _ => ListView(
                    key: key,
                    children: <Widget>[
                      for (final (i, _) in notes.indexed)
                        _buildTile(
                          context,
                          i,
                        ),
                      const EmptyFooter(),
                    ],
                  ),
              };
            },
        }();
        return CustomAnimatedSwitcher(
          child: child,
        );
      },
    );
  }
}

extension on BuildContext {
  HomeBloc get bloc {
    return read<HomeBloc>();
  }
}
