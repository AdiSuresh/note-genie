import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:note_maker/models/note/model.dart';

class NoteListTile extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteListTile({
    super.key,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var content = Document.fromJson(
      note.content,
    ).toPlainText().trim();
    content = content.isEmpty ? 'No content' : content;
    final height = MediaQuery.of(context).size.height;
    final textTheme = Theme.of(context).textTheme;
    final borderRadius = BorderRadius.circular(7.5);
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7.5,
        horizontal: 15,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          padding: const EdgeInsets.all(15),
          constraints: BoxConstraints(
            minHeight: height * .075,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade500,
                offset: const Offset(2.5, 2.5),
                blurRadius: 15,
                spreadRadius: 1,
              ),
              /* const BoxShadow(
                color: Colors.white,
                offset: Offset(-2.5, -2.5),
                blurRadius: 10,
                spreadRadius: 1,
              ), */
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: textTheme.titleMedium,
              ),
              Text(
                content,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
