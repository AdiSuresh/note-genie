import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/app/router/extra_variable/bloc.dart';
import 'package:note_maker/data/note/dao.dart';
import 'package:note_maker/models/note/note.dart';
import 'package:note_maker/utils/extensions/state.dart';
import 'package:note_maker/utils/ui_utils.dart';

class EditNote extends StatefulWidget {
  static const routeName = '/edit-note';

  const EditNote({
    super.key,
  });

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  final logger = AppLogger(
    EditNote,
  );

  final titleCtrl = TextEditingController();
  late final QuillController contentCtrl;
  late final QuillConfigurations quillConfigs;

  final contentFocus = FocusNode();

  final contentScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    Document? document;
    if (context.extra is Note) {
      note = context.extra;
      document = Document.fromJson(
        note!.content,
      );
    }
    titleCtrl.text = note?.title ?? '';
    contentCtrl = QuillController(
      document: document ?? Document(),
      selection: const TextSelection.collapsed(
        offset: 0,
      ),
    );
    contentCtrl.addListener(
      () {
        logger.d(
          'change detected',
        );
        saveDocument();
      },
    );
    quillConfigs = QuillConfigurations(
      controller: contentCtrl,
    );
  }

  @override
  void dispose() {
    contentCtrl.dispose();
    contentFocus.dispose();
    contentScrollCtrl.dispose();
    super.dispose();
  }

  void textField() {
    TextField(
      controller: titleCtrl,
      decoration: const InputDecoration(
        hintText: 'Title',
      ),
    );
  }

  String get title {
    final titleTrimmed = titleCtrl.text.trim();
    return titleTrimmed.isEmpty ? 'Untitled document' : titleTrimmed;
  }

  Note? note;

  final noteDao = NoteDao();

  Future<void> saveDocument() async {
    final content = contentCtrl.document.toDelta().toJson();
    note ??= Note(
      title: title,
      content: content,
      collections: {},
    );
    note = note?.copyWith(
      content: content,
    );
    if (note?.id == null) {
      final id = await noteDao.insert(
        note!,
      );
      note = note?.copyWith(
        id: id,
      );
    } else {
      noteDao.update(
        note!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        UiUtils.dismissKeyboard(context);
      },
      child: Scaffold(
        /* appBar: AppBar(
          title: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 7.5,
              ),
              child: Builder(
                builder: (context) {
                  final title = titleCtrl.text.isEmpty
                      ? 'Untitled document'
                      : titleCtrl.text;
                  return Text(
                    title,
                  );
                },
              ),
            ),
          ),
        ), */
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: QuillProvider(
              configurations: quillConfigs,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 7.5,
                    ),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(7.5),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7.5,
                          horizontal: 15,
                        ),
                        child: Text(
                          title,
                          style: themeData.textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(7.5),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFF5F5F4,
                        ),
                        borderRadius: BorderRadius.circular(7.5),
                      ),
                      child: QuillEditor(
                        configurations: const QuillEditorConfigurations(
                          readOnly: false,
                          padding: EdgeInsets.all(7.5),
                          scrollPhysics: BouncingScrollPhysics(),
                        ),
                        focusNode: contentFocus,
                        scrollController: contentScrollCtrl,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 15,
                    ),
                    child: QuillToolbar(
                      configurations: QuillToolbarConfigurations(
                        multiRowsDisplay: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
