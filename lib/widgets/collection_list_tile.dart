import 'package:flutter/material.dart';
import 'package:note_maker/models/note_collection/model.dart';

class CollectionListTile extends StatelessWidget {
  final NoteCollectionEntity collection;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRemoveNote;

  const CollectionListTile({
    super.key,
    required this.collection,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onRemoveNote,
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
                    if (onEdit != null)
                      IconButton(
                        tooltip: 'Edit title',
                        onPressed: onEdit,
                        icon: const Icon(
                          Icons.edit_outlined,
                        ),
                      ),
                    if (onDelete != null)
                      IconButton(
                        tooltip: 'Delete collection',
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outlined,
                        ),
                      ),
                    if (onRemoveNote != null)
                      IconButton(
                        tooltip: 'Remove from collection',
                        onPressed: onRemoveNote,
                        icon: const Icon(
                          Icons.remove_circle_outline,
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
