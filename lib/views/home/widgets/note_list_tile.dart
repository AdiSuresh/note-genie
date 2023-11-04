import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:note_maker/models/note/note.dart';

class NoteListTile extends StatelessWidget {
  final Note note;

  const NoteListTile({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    var content = Document.fromJson(
      note.content,
    ).toPlainText().trim();
    content = content.isEmpty ? 'No content' : content;
    final height = MediaQuery.of(context).size.height;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(15).copyWith(
        top: 7.5,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 7.5,
        horizontal: 15,
      ),
      constraints: BoxConstraints(
        minHeight: height * .075,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(7.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade500,
            offset: const Offset(2.5, 2.5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-2.5, -2.5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
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
              color: Colors.grey,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
