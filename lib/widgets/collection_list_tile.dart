import 'package:flutter/material.dart';
import 'package:note_maker/models/note_collection/model.dart';

class CollectionListTile extends StatelessWidget {
  final NoteCollectionEntity collection;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddNote;
  final VoidCallback? onRemoveNote;

  const CollectionListTile({
    super.key,
    required this.collection,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onAddNote,
    this.onRemoveNote,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final borderRadius = BorderRadius.circular(15);
    final actionButtonData = [
      ('Edit title', onEdit, Icons.edit_outlined),
      ('Delete collection', onDelete, Icons.delete_outlined),
      ('Add to collection', onAddNote, Icons.add_circle_outline),
      ('Remove from collection', onRemoveNote, Icons.remove_circle_outline),
    ];
    final actionButtons = [
      for (final (tooltip, onPressed, icon) in actionButtonData)
        if (onPressed != null)
          IconButton(
            tooltip: tooltip,
            onPressed: onPressed,
            icon: Icon(
              icon,
            ),
          ),
    ];
    final card = Card(
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
                children: actionButtons,
              ),
            ],
          ),
        ),
      ),
    );
    if (onTap == null) {
      return card;
    }
    return Tooltip(
      message: 'Show notes in ${collection.name}',
      child: card,
    );
  }
}
