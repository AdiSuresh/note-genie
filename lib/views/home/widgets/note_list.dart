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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) {
        switch ((previous, current)) {
          case (
              final IdleState previous,
              final IdleState current,
            ):
            return previous.notes != current.notes;
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
              SelectNotesState(),
              SelectNotesState(),
            ):
            return true;
          case (
              DeleteNotesState(),
              IdleState(),
            ):
            return false;
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
          null => const SizedBox(),
          (_, []) => const Center(
              child: Text(
                'No notes yet',
              ),
            ),
          (final currentCollection, final notes) => ListView(
              key: PageStorageKey(
                switch (state) {
                  SearchState() => notes,
                  _ => currentCollection ?? notes,
                },
              ),
              children: <Widget>[
                for (final (i, _) in notes.indexed)
                  _NoteListTileWrapper(
                    index: i,
                  ),
                const EmptyFooter(),
              ],
            ),
        };
        return CustomAnimatedSwitcher(
          child: child,
        );
      },
    );
  }
}

class _NoteListTileWrapper extends StatelessWidget {
  final int index;

  const _NoteListTileWrapper({
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HomeBloc>();
    final state = bloc.state;
    final note = switch (state) {
      final IdleState state => state.notes[index],
      final NonIdleState state => state.previousState.notes[index],
      DeleteItemsState(
        previousState: NonIdleState(
          :final previousState,
        ),
      ) =>
        previousState.notes[index],
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
            bloc.add(
              SelectNoteEvent(
                index: index,
              ),
            );
          },
        _ => null,
      },
      onLongPress: switch (state) {
        IdleState() => () {
            bloc.add(
              SelectNoteEvent(
                index: index,
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
        selected[index],
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
            when selected[index] =>
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
}
