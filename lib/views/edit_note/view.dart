import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/data/objectbox_db.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/utils/ui_utils.dart';
import 'package:note_maker/utils/text_input_validation/validators.dart';
import 'package:note_maker/views/edit_note/bloc.dart';
import 'package:note_maker/views/edit_note/event.dart';
import 'package:note_maker/views/edit_note/state.dart';
import 'package:note_maker/widgets/dismiss_keyboard.dart';

class EditNote extends StatefulWidget {
  static const path = '/edit-note';

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
  final titleFormKey = GlobalKey<FormState>();

  late final QuillController contentCtrl;
  final contentFocus = FocusNode();
  final contentScrollCtrl = ScrollController();

  EditNoteBloc get bloc => context.read<EditNoteBloc>();
  NoteEntity get note => bloc.state.note;

  StreamSubscription<DocChange>? changesSub;

  var documentJson = <dynamic>[];

  final db = ObjectBoxDB();

  @override
  void initState() {
    super.initState();
    final note = this.note;
    titleCtrl.text = note.title;
    documentJson = note.contentAsJson;
    final document = switch (documentJson) {
      [] => Document(),
      _ => Document.fromJson(
          documentJson,
        ),
    };
    changesSub = document.changes.listen(
      (event) async {
        logger.d(
          'updating document...',
        );
        final note = await saveContent();
        bloc.add(
          UpdateNoteEvent(
            note: note,
          ),
        );
      },
    );
    contentCtrl = QuillController(
      document: document,
      selection: const TextSelection.collapsed(
        offset: 0,
      ),
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

  Future<NoteEntity> saveContent() async {
    return saveNote(
      note.copyWith(
        content: jsonEncode(
          contentCtrl.document.toDelta().toJson(),
        ),
      ),
    );
  }

  Future<NoteEntity> saveTitle() async {
    return saveNote(
      note.copyWith(
        title: titleCtrl.text,
      ),
    );
  }

  Future<NoteEntity> saveNote(
    NoteEntity note,
  ) async {
    return db.store.then(
      (value) {
        return note.copyWith(
          id: value.box<NoteEntity>().put(
                note,
              ),
        );
      },
    );
  }

  Future<void> deleteNote() async {
    final deleted = await db.store.then(
      (value) {
        return value.box<NoteEntity>().remove(
              note.id,
            );
      },
    );
    final title = "'${note.title}'";
    final content = switch (deleted) {
      true => () {
          logger.d(
            'deleted note with id: ${note.id}',
          );
          changesSub?.pause();
          return '$title was deleted successfully';
        },
      _ => () {
          return 'Could not delete $title';
        },
    }();
    if (mounted) {
      UiUtils.showSnackbar(
        context,
        content: content,
        onClose: () {
          if (deleted) {
            context.pop();
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 7.5,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
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
                                onOk: () async {
                                  switch (
                                      titleFormKey.currentState?.validate()) {
                                    case true:
                                      saveTitle();
                                      context.pop();
                                      bloc.add(
                                        UpdateTitleEvent(
                                          title: titleCtrl.text,
                                        ),
                                      );
                                    case _:
                                  }
                                },
                                onCancel: () {
                                  context.pop();
                                },
                                validator: Validators.nonEmptyFieldValidator,
                                formKey: titleFormKey,
                              );
                            },
                            borderRadius: BorderRadius.circular(7.5),
                            child: Padding(
                              padding: const EdgeInsets.all(7.5),
                              child: BlocBuilder<EditNoteBloc, EditNoteState>(
                                buildWhen: (previous, current) {
                                  final t1 = previous.note.title;
                                  final t2 = current.note.title;
                                  return t1 != t2;
                                },
                                builder: (context, state) {
                                  return Text(
                                    state.note.title,
                                    style:
                                        context.themeData.textTheme.titleLarge,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                              left: 5,
                            ),
                            child: Text(
                              'Saving...',
                            ),
                          ),
                          PopupMenuButton(
                            color: Colors.white,
                            surfaceTintColor: Colors.white,
                            itemBuilder: (context) {
                              const style = TextStyle(
                                fontWeight: FontWeight.normal,
                              );
                              return [
                                PopupMenuItem(
                                  child: const Text(
                                    'Collections',
                                    style: style,
                                  ),
                                  onTap: () {},
                                ),
                                PopupMenuItem(
                                  child: const Text(
                                    'Linked Notes',
                                    style: style,
                                  ),
                                  onTap: () {},
                                ),
                                PopupMenuItem(
                                  child: Text(
                                    'Delete',
                                    style: style.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                  onTap: () {
                                    UiUtils.showProceedDialog(
                                      title: 'Delete note?',
                                      message:
                                          'You are about to delete this note.'
                                          ' Once deleted its gone forever.'
                                          '\n\nAre you sure you want to proceed?',
                                      context: context,
                                      onYes: () {
                                        context.pop();
                                        deleteNote();
                                      },
                                      onNo: () {
                                        context.pop();
                                      },
                                    );
                                  },
                                ),
                              ];
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: QuillEditor(
                    configurations: const QuillEditorConfigurations(
                      padding: EdgeInsets.all(7.5),
                      scrollPhysics: BouncingScrollPhysics(),
                    ),
                    focusNode: contentFocus,
                    scrollController: contentScrollCtrl,
                    controller: contentCtrl,
                  ),
                ),
                /* const Padding(
                    padding: EdgeInsets.only(
                      top: 15,
                    ),
                    child: QuillToolbar(
                      configurations: QuillToolbarConfigurations(
                        multiRowsDisplay: false,
                      ),
                    ),
                  ), */
              ],
            ),
          ),
        ),
      ),
    );
  }
}
