import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/utils/extensions/iterable.dart';
import 'package:note_maker/views/home/bloc.dart';
import 'package:note_maker/views/home/event.dart';
import 'package:note_maker/views/home/state/state.dart';
import 'package:note_maker/views/home/widgets/collection_chip.dart';
import 'package:note_maker/views/home/widgets/no_collections_message.dart';

class NoteCollectionTabList extends StatelessWidget {
  static const animationDuration = Duration(
    milliseconds: 150,
  );

  const NoteCollectionTabList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HomeBloc>();
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: bloc,
      buildWhen: (previous, current) {
        switch ((previous, current)) {
          case (final IdleState previous, final IdleState current):
            return [
              previous.noteCollections != current.noteCollections,
              previous.currentCollection?.id != current.currentCollection?.id,
            ].or();
          case _:
        }
        return false;
      },
      builder: (context, state) {
        if (state case IdleState()) {
          const verticalPadding = EdgeInsets.symmetric(
            vertical: 7.5,
          );
          final collections = state.noteCollections;
          if (collections case []) {
            return NoCollectionsMessage();
          }
          final currentCollection = state.currentCollection;
          return SingleChildScrollView(
            key: const PageStorageKey(
              'note-collection-tab-list',
            ),
            padding: verticalPadding,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: collections.map(
                (collection) {
                  return Builder(
                    key: GlobalObjectKey(
                      collection,
                    ),
                    builder: (context) {
                      var padding = const EdgeInsets.symmetric(
                        horizontal: 7.5,
                      );
                      if (collection == collections.first) {
                        padding = padding.copyWith(
                          left: 15,
                        );
                      }
                      final selected = collection.id == currentCollection?.id;
                      final scale = selected ? 1.05 : 1.0;
                      final borderColor = switch (selected) {
                        true => Colors.blueGrey.withOpacity(
                            .5,
                          ),
                        _ => Colors.transparent,
                      };
                      return Padding(
                        padding: padding,
                        child: AnimatedContainer(
                          duration: animationDuration,
                          transform: Transform.scale(
                            scale: scale,
                          ).transform,
                          transformAlignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: borderColor,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            ),
                            borderRadius: BorderRadius.circular(
                              15,
                            ),
                          ),
                          child: CollectionChip(
                            onTap: () {
                              bloc.add(
                                ToggleCollectionEvent(
                                  collection: collection,
                                ),
                              );
                            },
                            child: Text(
                              collection.name,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ).toList(),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
