import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/data/services/objectbox_db.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/utils/extensions/draggable_scrollable_controller.dart';
import 'package:note_maker/utils/ui_utils.dart';
import 'package:note_maker/utils/text_input_validation/validators.dart';
import 'package:note_maker/views/edit_note/bloc.dart';
import 'package:note_maker/views/edit_note/event.dart';
import 'package:note_maker/views/edit_note/state/state.dart';
import 'package:note_maker/views/edit_note/widgets/note_collection_list_sheet.dart';
import 'package:note_maker/widgets/custom_animated_switcher.dart';
import 'package:note_maker/widgets/dismiss_keyboard.dart';
import 'package:note_maker/widgets/draggable_scrollable_bloc/bloc.dart';

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
    milliseconds: 250,
  );

  final db = ObjectBoxDB();

  final titleCtrl = TextEditingController();
  final titleFormKey = GlobalKey<FormState>();

  late final QuillController contentCtrl;
  final contentFocus = FocusNode();
  final contentScrollCtrl = ScrollController();

  StreamSubscription<DocChange>? docChangesSub;

  DraggableScrollableController get sheetCtrl {
    return sheetBloc.controller;
  }

  var documentJson = <dynamic>[];

  EditNoteBloc get bloc => context.read<EditNoteBloc>();
  NoteEntity get note => bloc.state.note;

  DraggableScrollableBloc get sheetBloc {
    return context.read<DraggableScrollableBloc>();
  }

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
        bloc.add(
          UpdateContentEvent(
            document: contentCtrl.document,
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
    super.dispose();
  }

  void onEditorFocus() {
    sheetCtrl.jumpTo(
      0,
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
            bloc.add(
              UpdateTitleEvent(
                title: titleCtrl.text,
              ),
            );
            context.pop();
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
      UiUtils.showSnackBar(
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        if (await sheetCtrl.isAnimating()) {
          return;
        }
        if (sheetBloc.state.isOpen) {
          sheetCtrl.animateTo(
            0,
            duration: animationDuration,
            curve: Curves.ease,
          );
          return;
        }
        if (contentFocus.hasFocus) {
          await Future.delayed(
            const Duration(
              milliseconds: 25,
            ),
          );
          contentFocus.unfocus();
          return;
        }
        if (context.mounted) {
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
                    return previous.note.title != current.note.title;
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
              Padding(
                padding: const EdgeInsets.only(
                  left: 5,
                ),
                child: BlocBuilder<EditNoteBloc, EditNoteState>(
                  buildWhen: (previous, current) {
                    return previous.noteStatus != current.noteStatus;
                  },
                  builder: (context, state) {
                    return CustomAnimatedSwitcher(
                      child: Text(
                        key: ValueKey(
                          state.noteStatus,
                        ),
                        state.noteStatus.message,
                      ),
                    );
                  },
                ),
              ),
              BlocBuilder<EditNoteBloc, EditNoteState>(
                buildWhen: (previous, current) {
                  return previous.note.id != current.note.id;
                },
                builder: (context, state) {
                  if (note.id == 0) {
                    return const SizedBox();
                  }
                  return PopupMenuButton(
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
                            sheetCtrl.animateTo(
                              1,
                              duration: animationDuration,
                              curve: Curves.ease,
                            );
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
                  );
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
                const NoteCollectionListSheet(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
