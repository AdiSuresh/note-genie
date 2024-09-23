import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/data/objectbox_db.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/utils/ui_utils.dart';
import 'package:note_maker/utils/text_input_validation/validators.dart';
import 'package:note_maker/views/edit_note/bloc.dart';
import 'package:note_maker/views/edit_note/event.dart';
import 'package:note_maker/views/edit_note/state/state.dart';
import 'package:note_maker/views/edit_note/widgets/note_collection_list_sheet.dart';
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
  static final logger = AppLogger(
    EditNote,
  );

  static const animationDuration = Duration(
    milliseconds: 150,
  );

  final db = ObjectBoxDB();

  final titleCtrl = TextEditingController();
  final titleFormKey = GlobalKey<FormState>();

  late final QuillController contentCtrl;
  final contentFocus = FocusNode();
  final contentScrollCtrl = ScrollController();

  StreamSubscription<DocChange>? docChangesSub;

  final sheetCtrl = DraggableScrollableController();

  var documentJson = <dynamic>[];

  EditNoteBloc get bloc => context.read<EditNoteBloc>();
  NoteEntity get note => bloc.state.note;

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
    docChangesSub = document.changes.listen(
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
    contentFocus.addListener(
      onEditorFocus,
    );
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    contentCtrl.dispose();
    contentFocus.removeListener(
      onEditorFocus,
    );
    contentFocus.dispose();
    contentScrollCtrl.dispose();
    docChangesSub?.cancel();
    sheetCtrl.dispose();
    super.dispose();
  }

  void onEditorFocus() {
    sheetCtrl.jumpTo(
      0,
    );
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
    final title = switch (titleCtrl.text.trim()) {
      '' => 'Untitled',
      final s => s,
    };
    return saveNote(
      note.copyWith(
        title: title,
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

  void renameNote() {
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
        switch (titleFormKey.currentState?.validate()) {
          case true:
            final note = await saveTitle();
            if (mounted) {
              context.pop();
            }
            bloc.add(
              UpdateNoteEvent(
                note: note,
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
  }

  Future<void> deleteNote() async {
    final deleted = await db.store.then(
      (value) {
        return value.box<NoteEntity>().remove(
              note.id,
            );
      },
    );
    if (deleted) {
      logger.d(
        'deleted note with id: ${note.id}',
      );
      docChangesSub?.pause();
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
        onClose: () {
          if (deleted && mounted) {
            context.go(
              '/',
            );
          }
        },
      );
    }
  }

  Future<void> removeFromCollection(
    NoteCollectionEntity collection,
  ) async {
    note.collections
      ..removeWhere(
        (element) {
          return element.id == collection.id;
        },
      )
      ..applyToDb();
    bloc.add(
      UpdateNoteEvent(
        note: note,
      ),
    );
    final noteTitle = "'${note.title}'";
    final collectionTitle = "'${collection.name}'";
    final content = '$noteTitle was removed from $collectionTitle';
    if (mounted) {
      UiUtils.showSnackbar(
        context,
        content: content,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        if (sheetCtrl.pixels > 0) {
          sheetCtrl.animateTo(
            0,
            duration: const Duration(
              seconds: 5,
            ),
            curve: Curves.linear,
          );
          return;
        }
        if (contentFocus.hasFocus) {
          contentFocus.unfocus();
          return;
        }
        if (mounted) {
          context.pop(
            result,
          );
        }
      },
      child: DismissKeyboard(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: InkWell(
              onTap: renameNote,
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
            actions: [
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
                onOpened: () {
                  contentFocus.unfocus();
                },
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
                      onTap: () async {
                        await sheetCtrl.animateTo(
                          1,
                          duration: animationDuration,
                          curve: Curves.ease,
                        );
                        switch (this.context) {
                          case BuildContext context when context.mounted:
                            UiUtils.dismissKeyboard(
                              context,
                            );
                          case _:
                        }
                      },
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
                        final context = this.context;
                        UiUtils.showProceedDialog(
                          title: 'Delete note?',
                          message: 'You are about to delete this note.'
                              ' Once deleted its gone forever.'
                              '\n\nAre you sure you want to proceed?',
                          context: context,
                          onYes: () {
                            logger.i('on yes');
                            context.pop();
                            // return;
                            deleteNote();
                          },
                          onNo: () {
                            logger.i('on no');
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
          body: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                QuillEditor(
                  configurations: const QuillEditorConfigurations(
                    padding: EdgeInsets.all(15),
                    scrollPhysics: BouncingScrollPhysics(),
                  ),
                  focusNode: contentFocus,
                  scrollController: contentScrollCtrl,
                  controller: contentCtrl,
                ),
                NoteCollectionListSheet(
                  controller: sheetCtrl,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
