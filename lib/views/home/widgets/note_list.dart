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
              SearchNotesState(),
              SearchNotesState(),
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
          _ => null,
        };
        final child = switch (data) {
          null => () {
              return const SizedBox();
            },
          (final currentCollection, final notes) => () {
              final key = switch (state) {
                IdleState() => PageStorageKey(
                    currentCollection,
                  ),
                SearchState(
                  :final query,
                ) =>
                  PageStorageKey(
                    'note-list-search/q=$query',
                  ),
                SelectItemsState() => PageStorageKey(
                    'note-list-select',
                  ),
              };
              return switch (notes) {
                [] => const Center(
                    child: Text(
                      'No notes yet',
                    ),
                  ),
                _ => ListView(
                    key: key,
                    children: <Widget>[
                      for (final note in notes)
                        NoteListTile(
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
                                    item: note,
                                  ),
                                );
                              case _:
                            }
                          },
                          onLongPress: switch (state) {
                            IdleState() => () {
                                context.bloc.add(
                                  SelectNoteEvent(
                                    item: note,
                                  ),
                                );
                              },
                            _ => null,
                          },
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
