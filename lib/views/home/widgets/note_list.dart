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
      final IdleState state => state.notes[i],
      final NonIdleState state => state.previousState.notes[i],
      DeleteItemsState(
        previousState: NonIdleState(
          :final previousState,
        ),
      ) =>
        previousState.notes[i],
    };
    final splash = switch (state) {
      SelectNotesState() => false,
      _ => true,
    };
    final tile = NoteListTile(
      note: note,
      onTap: switch (state) {
        IdleState() || SearchNotesState() => () {
            context
              ..extra = note
              ..go(
                (EditNote).asRoutePath(),
              );
          },
        SelectNotesState() => () {
            context.bloc.add(
              SelectNoteEvent(
                index: i,
              ),
            );
          },
        _ => null,
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
      splash: splash,
    );
    final selected = switch (state) {
      SelectNotesState(
        :final selected,
      ) =>
        selected[i],
      _ => false,
    };
    return AnimatedSwitcher(
      duration: const Duration(
        milliseconds: 250,
      ),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            child: child,
          ),
        );
      },
      child: switch (state) {
        DeleteNotesState(
          previousState: SelectNotesState(
            :final selected,
          ),
        )
            when selected[i] =>
          const SizedBox(),
        _ => Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 7.5,
              horizontal: 15,
            ),
            child: SelectionHighlight(
              selected: selected,
              scaleFactor: 1.0125,
              child: tile,
            ),
          ),
      },
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
          DeleteNotesState(
            previousState: SelectNotesState(
              :final previousState,
            ),
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
                  SelectItemsState() ||
                  DeleteItemsState() =>
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
