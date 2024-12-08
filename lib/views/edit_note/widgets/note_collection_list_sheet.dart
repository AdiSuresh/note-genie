import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/utils/extensions/iterable.dart';
import 'package:note_maker/utils/ui_utils.dart';
import 'package:note_maker/views/edit_note/bloc.dart';
import 'package:note_maker/views/edit_note/event.dart';
import 'package:note_maker/views/edit_note/state/state.dart';
import 'package:note_maker/views/home/widgets/no_collections_message.dart';
import 'package:note_maker/widgets/custom_animated_switcher.dart';
import 'package:note_maker/widgets/draggable_scrollable_bloc/bloc.dart';
import 'package:note_maker/widgets/draggable_scrollable_bloc/state.dart';
import 'package:note_maker/widgets/note_collection_list_tile.dart';

class NoteCollectionListSheet extends StatefulWidget {
  const NoteCollectionListSheet({
    super.key,
  });

  @override
  State<NoteCollectionListSheet> createState() {
    return _NoteCollectionListSheetState();
  }
}

class _NoteCollectionListSheetState extends State<NoteCollectionListSheet> {
  EditNoteBloc get bloc => context.read<EditNoteBloc>();
  NoteEntity get note => bloc.state.note;

  DraggableScrollableBloc get sheetBloc {
    return context.read<DraggableScrollableBloc>();
  }

  void removeFromCollection(
    NoteCollectionEntity collection,
  ) {
    final collectionTitle = "'${collection.name}'";
    UiUtils.showProceedDialog(
      title: 'Remove note from collection?',
      message: 'You are about to this note from'
          ' $collectionTitle.'
          '\n\nAre you sure you want to proceed?',
      context: context,
      onYes: () {
        context.pop();
        bloc.add(
          RemoveFromCollectionEvent(
            collectionId: collection.id,
          ),
        );
        final noteTitle = "'${note.title}'";
        final collectionTitle = "'${collection.name}'";
        final content = '$noteTitle was removed from $collectionTitle';
        if (mounted) {
          UiUtils.showSnackBar(
            context,
            content: content,
          );
        }
      },
      onNo: () {
        context.pop();
      },
    );
  }

  void addToCollection(
    NoteCollectionEntity collection,
  ) {
    bloc.add(
      AddToCollectionEvent(
        collection: collection,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      minChildSize: 0,
      initialChildSize: 0,
      controller: sheetBloc.controller,
      snapSizes: const [
        0,
      ],
      snap: true,
      builder: (context, scrollController) {
        final builder = BlocBuilder<EditNoteBloc, EditNoteState>(
          bloc: context.watch<EditNoteBloc>(),
          buildWhen: (previous, current) {
            final l1 = previous.note.collections.length;
            final l2 = current.note.collections.length;
            return [
              l1 != l2,
              previous.viewCollections ^ current.viewCollections,
              previous.unlinkedCollections != current.unlinkedCollections,
            ].or();
          },
          builder: (context, state) {
            final (viewTitle, collections) = switch (state.viewCollections) {
              true => ('Found in...', state.note.collections),
              _ => ('Add to...', state.unlinkedCollections),
            };
            final listViewChildren = <Widget>[
              Text(
                viewTitle,
                style: context.themeData.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (collections.isEmpty)
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.30,
                  ),
                  child: const Center(
                    child: NoCollectionsMessage(),
                  ),
                ),
              ...collections.map(
                (collection) {
                  final (removeNote, addNote) = switch (state.viewCollections) {
                    true => (() => removeFromCollection(collection), null),
                    _ => (null, () => addToCollection(collection)),
                  };
                  return NoteCollectionListTile(
                    collection: collection,
                    onRemoveNote: removeNote,
                    onAddNote: addNote,
                  );
                },
              ),
            ].map(
              (e) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 15,
                  ),
                  child: e,
                );
              },
            ).toList();
            final viewKey = ValueKey(
              'view-collections:${state.viewCollections}',
            );
            final listView = ListView(
              key: viewKey,
              controller: scrollController,
              padding: const EdgeInsets.all(15),
              children: listViewChildren,
            );
            final (tooltip, label, iconData) = switch (state.viewCollections) {
              true => ('Add to collection', 'Add', Icons.playlist_add),
              _ => ('View collections', 'View', Icons.view_list_rounded),
            };
            final fab = FloatingActionButton.extended(
              heroTag: null,
              tooltip: tooltip,
              label: Text(
                label,
              ),
              icon: Icon(
                iconData,
              ),
              elevation: 2.5,
              onPressed: () {
                final event = switch (state.viewCollections) {
                  true => const ViewUnlinkedCollectionsEvent(),
                  _ => const ViewCollectionsEvent(),
                };
                bloc.add(
                  event,
                );
              },
            );
            return Stack(
              children: [
                CustomAnimatedSwitcher(
                  child: listView,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 15,
                  child: Center(
                    child: fab,
                  ),
                ),
              ],
            );
          },
        );
        return BlocBuilder<DraggableScrollableBloc, DraggableScrollableState>(
          bloc: context.watch<DraggableScrollableBloc>(),
          buildWhen: (previous, current) {
            return previous.isOpen ^ current.isOpen;
          },
          builder: (context, state) {
            final boxShadow = switch (state.isOpen) {
              true => [
                  const BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 2.5,
                    blurRadius: 2.5,
                    offset: Offset(0, -1),
                  ),
                ],
              _ => null,
            };
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: boxShadow,
              ),
              child: builder,
            );
          },
        );
      },
    );
  }
}
