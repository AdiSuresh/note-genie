import 'package:flutter/material.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/widgets/custom_animated_switcher.dart';

class NoteCollectionListTile extends StatelessWidget {
  final NoteCollectionEntity collection;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onAddNote;
  final VoidCallback? onRemoveNote;
  final bool splash;

  const NoteCollectionListTile({
    super.key,
    required this.collection,
    this.onTap,
    this.onLongPress,
    this.onEdit,
    this.onAddNote,
    this.onRemoveNote,
    this.splash = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final borderRadius = BorderRadius.circular(15);
    final actionButtonData = [
      ('Edit title', onEdit, Icons.edit_outlined),
      ('Add to collection', onAddNote, Icons.add_circle_outline),
      ('Remove from collection', onRemoveNote, Icons.remove_circle_outline),
    ];
    final actionButtons = <Widget>[
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
        onLongPress: onLongPress,
        borderRadius: borderRadius,
        splashColor: splash ? null : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                collection.name,
                style: textTheme.titleMedium,
              ),
              CustomAnimatedSwitcher(
                child: switch (actionButtons) {
                  [] => Opacity(
                      opacity: 0,
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.abc,
                        ),
                      ),
                    ),
                  _ => Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: actionButtons,
                    ),
                },
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
