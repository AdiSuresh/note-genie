import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/views/edit_note/bloc.dart';
import 'package:note_maker/views/edit_note/event.dart';
import 'package:note_maker/views/edit_note/state/state.dart';

class EditNoteFab extends StatelessWidget {
  const EditNoteFab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditNoteBloc, EditNoteState>(
      bloc: context.watch<EditNoteBloc>(),
      buildWhen: (previous, current) {
        return previous.viewCollections ^ current.viewCollections;
      },
      builder: (context, state) {
        final (tooltip, iconData) = switch (state.viewCollections) {
          true => ('Add to collection', Icons.playlist_add),
          _ => ('View collections', Icons.view_list_rounded),
        };
        return FloatingActionButton(
          tooltip: tooltip,
          onPressed: () {
            final event = switch (state.viewCollections) {
              true => const ViewUnlinkedCollectionsEvent(),
              _ => const ViewCollectionsEvent(),
            };
            context.read<EditNoteBloc>().add(
                  event,
                );
          },
          child: Icon(
            iconData,
          ),
        );
      },
    );
  }
}
