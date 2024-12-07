import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/views/home/bloc.dart';
import 'package:note_maker/views/home/state/state.dart';

class HomePageTitle extends StatelessWidget {
  const HomePageTitle({
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
            return previous.pageTitle != current.pageTitle;
          case (_, IdleState()):
            return true;
          case (IdleState(), SelectItemsState()):
            return true;
          case (
              final SelectItemsState previous,
              final SelectItemsState current,
            ):
            return previous.count != current.count;
          case _:
        }
        return false;
      },
      builder: (context, state) {
        if (state case SelectItemsState()) {
          [
            state.count,
            'selected',
            if (state.previousState.currentCollection?.name case String name)
              'in $name',
          ];
        }
        final pageTitle = switch (state) {
          IdleState() => state.pageTitle,
          final SelectItemsState state => [
              state.count,
              'selected',
              if (state
                  case SelectNotesState(
                    previousState: IdleState(
                      currentCollection: NoteCollectionEntity(
                        name: final name,
                      ),
                    ),
                  ))
                'in $name',
            ].join(
              ' ',
            ),
          _ => null,
        };
        return switch (pageTitle) {
          null => const SizedBox(),
          _ => Text(
              pageTitle,
              style: context.themeData.textTheme.titleLarge,
            ),
        };
      },
    );
  }
}
