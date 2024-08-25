import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/utils/ui_utils.dart';
import 'package:note_maker/utils/text_input_validation/validators.dart';
import 'package:note_maker/views/edit_note/bloc.dart';
import 'package:note_maker/views/edit_note/state.dart';

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
      (event) async {
        logger.d(
          'updating document...',
        );
        /* final note = await saveDocument();
        bloc.add(
          UpdateNoteEvent(
            note: note,
          ),
        ); */
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

  Completer<int>? addNoteCompleter;

  /* Future<Note> saveDocument({
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
      addNoteCompleter ??= Completer();
      addNoteCompleter?.complete(
        id,
      );
      return note.copyWith(
        id: id,
      );
    } else {
      if (addNoteCompleter != null) {
        await addNoteCompleter?.future;
      }
      await notes.update(
        note,
      );
      return note;
    }
  } */

  /* Future<void> deleteNote() async {
    final id = await NoteDao().delete(
      note,
    );
    final deleted = id != null;
    if (deleted) {
      logger.d(
        'deleted note with id: $id',
      );
      changesSub?.pause();
      if (mounted) {
        context.pop();
      }
    }
    final title = "'${note.title}'";
    final content = switch (deleted) {
      true => '$title was deleted successfully',
      _ => 'Could not delete $title',
    };
    if (mounted) {
      UiUtils.showSnackbar(
        context,
        content: content,
        onClose: () {},
      );
    }
  } */

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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 7.5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
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
                                final valid =
                                    titleFormKey.currentState?.validate() ??
                                        false;
                                if (!valid) {
                                  return;
                                }
                                /* final note = await saveDocument(
                                  title: titleCtrl.text,
                                );
                                bloc.add(
                                  UpdateNoteEvent(
                                    note: note,
                                  ),
                                ); */
                                if (mounted) {
                                  context.pop();
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
                                  style: context.themeData.textTheme.titleLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(
                                left: 5,
                              ),
                              child: Text(
                                '(Saving...)',
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
                                      'Colections',
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
                                            ' Are you sure you want to proceed?',
                                        context: context,
                                        onYes: () {
                                          context.pop();
                                          // deleteNote();
                                        },
                                        onNo: () {
                                          context.pop();
                                        },
                                      );
                                    },
                                  ),
                                ];
                              },
                              /* child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.more_vert,
                                  ),
                                ), */
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: QuillEditor(
                    configurations: QuillEditorConfigurations(
                      padding: const EdgeInsets.all(7.5),
                      scrollPhysics: const BouncingScrollPhysics(),
                      controller: contentCtrl,
                    ),
                    focusNode: contentFocus,
                    scrollController: contentScrollCtrl,
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
