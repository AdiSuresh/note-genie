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

  void removeFromCollection(
    NoteCollectionEntity collection,
  ) {
    bloc.add(
      RemoveFromCollectionEvent(
        collectionId: collection.id,
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
          bloc: context.watch<EditNoteBloc>(),
          buildWhen: (previous, current) {
            final l1 = previous.note.collections.length;
            final l2 = current.note.collections.length;
            return l1 != l2;
          },
          builder: (context, state) {
            final collections = state.note.collections;
            final listView = BlocBuilder<EditNoteBloc, EditNoteState>(
              bloc: context.watch<EditNoteBloc>(),
              buildWhen: (previous, current) {
                return previous.viewCollections ^ current.viewCollections;
              },
              builder: (context, state) {
                return switch (state.viewCollections) {
                  true => ListView(
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
                  _ => ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(15),
                      children: collections.map(
                        (collection) {
                          return CollectionListTile(
                            collection: collection,
                            onAddNote: () {},
                          );
                        },
                      ).toList(),
                    ),
                };
              },
            );
            return DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 2.5,
                    blurRadius: 2.5,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: switch (collections) {
                [] => Stack(
                    children: [
                      listView,
                      const Center(
                        child: NoCollectionsMessage(),
                      ),
                    ],
                  ),
                _ => listView,
              },
            );
          },
        );
      },
    );
  }
}
