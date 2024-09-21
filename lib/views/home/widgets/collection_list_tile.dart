import 'package:flutter/material.dart';
import 'package:note_maker/models/note_collection/model.dart';

class CollectionListTile extends StatelessWidget {
  final VoidCallback onTap;
  final NoteCollectionEntity collection;

  const CollectionListTile({
    super.key,
    required this.onTap,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final borderRadius = BorderRadius.circular(15);
    return Tooltip(
      message: 'Show notes in ${collection.name}',
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  collection.name,
                  style: textTheme.titleMedium,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: 'Edit title',
                      onPressed: () {},
                      icon: const Icon(
                        Icons.edit_outlined,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete collection',
                      onPressed: () {},
                      icon: const Icon(
                        Icons.delete_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
