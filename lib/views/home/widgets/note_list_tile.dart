import 'package:flutter/material.dart';
import 'package:note_maker/models/note/model.dart';

class NoteListTile extends StatelessWidget {
  final Note note;
  final VoidCallback viewNote;

  const NoteListTile({
    super.key,
    required this.note,
    required this.viewNote,
  });

  @override
  Widget build(BuildContext context) {
    var content = note.contentAsText;
    if (content.isEmpty) {
      content = 'No content';
    }
    final textTheme = Theme.of(context).textTheme;
    final borderRadius = BorderRadius.circular(15);
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7.5,
        horizontal: 15,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: viewNote,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'A minute ago',
                    style: textTheme.bodySmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 5,
                  ),
                  child: Text(
                    note.title,
                    style: textTheme.titleMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 5,
                  ),
                  child: Text(
                    content,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
