import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/utils/ui_utils.dart';
import 'package:note_maker/views/edit_note/bloc.dart';
import 'package:note_maker/views/edit_note/event.dart';
import 'package:note_maker/views/edit_note/state/state.dart';
import 'package:note_maker/views/home/widgets/no_collections_message.dart';
import 'package:note_maker/widgets/collection_list_tile.dart';

class NoteCollectionListSheet extends StatefulWidget {
  final DraggableScrollableController controller;

  const NoteCollectionListSheet({
    super.key,
    required this.controller,
  });

  @override
  State<NoteCollectionListSheet> createState() =>
      _NoteCollectionListSheetState();
}

class _NoteCollectionListSheetState extends State<NoteCollectionListSheet> {
  EditNoteBloc get bloc => context.read<EditNoteBloc>();
  NoteEntity get note => bloc.state.note;

  Future<void> removeFromCollection(
    NoteCollectionEntity collection,
  ) async {
    note.collections
      ..removeWhere(
        (element) {
          return element.id == collection.id;
        },
      )
      ..applyToDb();
    bloc.add(
      UpdateNoteEvent(
        note: note,
      ),
    );
    final noteTitle = "'${note.title}'";
    final collectionTitle = "'${collection.name}'";
    final content = '$noteTitle was removed from $collectionTitle';
    if (mounted) {
      UiUtils.showSnackbar(
        context,
        content: content,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      minChildSize: 0,
      initialChildSize: 0,
      controller: widget.controller,
      snapSizes: const [
        0,
      ],
      snap: true,
      builder: (context, scrollController) {
        return BlocBuilder<EditNoteBloc, EditNoteState>(
          buildWhen: (previous, current) {
            final l1 = previous.note.collections;
            final l2 = current.note.collections;
            return l1 != l2;
          },
          builder: (context, state) {
            final collections = state.note.collections;
            final children = <Widget>[
              ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(15),
                children: collections.map(
                  (collection) {
                    return CollectionListTile(
                      collection: collection,
                      onRemoveNote: () {
                        final collectionTitle = "'${collection.name}'";
                        UiUtils.showProceedDialog(
                          title: 'Remove note from collection?',
                          message: 'You are about to this note from'
                              ' $collectionTitle.'
                              '\n\nAre you sure you want to proceed?',
                          context: context,
                          onYes: () {
                            context.pop();
                            removeFromCollection(
                              collection,
                            );
                          },
                          onNo: () {
                            context.pop();
                          },
                        );
                      },
                    );
                  },
                ).toList(),
              ),
            ];
            if (collections case []) {
              children.add(
                const Center(
                  child: NoCollectionsMessage(),
                ),
              );
            }
            return DecoratedBox(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: Stack(
                children: children,
              ),
            );
          },
        );
      },
    );
  }
}
