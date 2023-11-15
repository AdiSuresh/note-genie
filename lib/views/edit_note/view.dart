import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/models/note/dao.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/utils/ui_utils.dart';
import 'package:note_maker/views/edit_note/bloc.dart';
import 'package:note_maker/views/edit_note/event.dart';
import 'package:note_maker/views/edit_note/state.dart';

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

  final notes = NoteDao();

  final titleCtrl = TextEditingController();
  late final QuillController contentCtrl;
  late final QuillConfigurations quillConfigs;
  final contentFocus = FocusNode();
  final contentScrollCtrl = ScrollController();

  EditNoteBloc get bloc => context.read();
  Note get note => bloc.state.note;

  StreamSubscription<DocChange>? changesSub;

  @override
  void initState() {
    super.initState();
    final note = bloc.state.note;
    titleCtrl.text = note.title;
    final document = note.content.isEmpty
        ? Document()
        : Document.fromJson(
            note.content,
          );
    changesSub = document.changes.listen(
      (event) {
        logger.d(
          'updating document...',
        );
        saveDocument();
      },
    );
    contentCtrl = QuillController(
      document: document,
      selection: const TextSelection.collapsed(
        offset: 0,
      ),
    );
    quillConfigs = QuillConfigurations(
      controller: contentCtrl,
    );
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    contentCtrl.dispose();
    contentFocus.dispose();
    contentScrollCtrl.dispose();
    changesSub?.cancel().whenComplete(
      () {
        logger.i(
          'changesSub disposed',
        );
      },
    );
    super.dispose();
  }

  Future<void> saveDocument({
    String? title,
  }) async {
    final content = contentCtrl.document.toDelta().toJson();
    final note = this.note.copyWith(
          title: title,
          content: content,
        );
    if (note.id == null) {
      final id = await notes.add(
        note,
      );
      bloc.add(
        UpdateNoteEvent(
          note: note.copyWith(
            id: id,
          ),
        ),
      );
    } else {
      notes.update(
        note,
      );
      bloc.add(
        UpdateNoteEvent(
          note: note,
        ),
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: QuillProvider(
              configurations: quillConfigs,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 7.5,
                      ),
                      child: InkWell(
                        onTap: () {
                          titleCtrl.text = note.title;
                          titleCtrl.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: titleCtrl.text.length,
                          );
                          UiUtils.showEditTitleDialog(
                            title: 'Rename document',
                            context: context,
                            titleCtrl: titleCtrl,
                            onOk: () {
                              saveDocument(
                                title: titleCtrl.text,
                              );
                              context.pop();
                            },
                            onCancel: () {
                              context.pop();
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(7.5),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 7.5,
                            horizontal: 15,
                          ),
                          child: BlocBuilder<EditNoteBloc, EditNoteState>(
                            buildWhen: (previous, current) {
                              final t1 = previous.note.title;
                              final t2 = current.note.title;
                              return t1 != t2;
                            },
                            builder: (context, state) {
                              return Text(
                                state.note.title,
                                style: context.themeData.textTheme.titleLarge,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(7.5),
                      decoration: BoxDecoration(
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
