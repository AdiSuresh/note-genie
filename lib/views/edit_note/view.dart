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
import 'package:note_maker/objectbox.g.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/utils/ui_utils.dart';
import 'package:note_maker/utils/text_input_validation/validators.dart';
import 'package:note_maker/views/edit_note/bloc.dart';
import 'package:note_maker/views/edit_note/event.dart';
import 'package:note_maker/views/edit_note/state/state.dart';
import 'package:note_maker/views/home/widgets/no_collections_message.dart';
import 'package:note_maker/widgets/collection_list_tile.dart';
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

  final db = ObjectBoxDB();

  final titleCtrl = TextEditingController();
  final titleFormKey = GlobalKey<FormState>();

  late final QuillController contentCtrl;
  final contentFocus = FocusNode();
  final contentScrollCtrl = ScrollController();

  StreamSubscription<DocChange>? docChangesSub;
  StreamSubscription<List<NoteCollectionEntity>>? noteCollectionsSub;

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
    startNoteCollectionsSub();
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
        startNoteCollectionsSub();
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
    docChangesSub?.cancel().whenComplete(
      () {
        logger.i(
          'changesSub disposed',
        );
      },
    );
    noteCollectionsSub?.cancel();
    super.dispose();
  }

  Future<void> startNoteCollectionsSub() async {
    if (note.id > 0 && noteCollectionsSub == null) {
      final store = await db.store;
      final builder = store.box<NoteCollectionEntity>().query()
        ..linkMany(
          NoteCollectionEntity_.notes,
          NoteEntity_.id.equals(
            note.id,
          ),
        );
      noteCollectionsSub = builder
          .watch(
            triggerImmediately: true,
          )
          .map(
            (query) => query.find(),
          )
          .listen(
        (noteCollections) {
          bloc.add(
            UpdateNoteCollectionsEvent(
              noteCollections: noteCollections,
            ),
          );
        },
      );
    }
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
    final title = "'${note.title}'";
    final content = switch (deleted) {
      true => () {
          logger.d(
            'deleted note with id: ${note.id}',
          );
          docChangesSub?.pause();
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
    return DismissKeyboard(
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
                        duration: const Duration(
                          milliseconds: 150,
                        ),
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
              DraggableScrollableSheet(
                minChildSize: 0,
                initialChildSize: 0,
                controller: sheetCtrl,
                snapSizes: const [
                  0,
                ],
                snap: true,
                builder: (context, scrollController) {
                  return BlocBuilder<EditNoteBloc, EditNoteState>(
                    buildWhen: (previous, current) {
                      return true;
                    },
                    builder: (context, state) {
                      final collections = state.note.collections;
                      final children = <Widget>[
                        ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(15),
                          children: collections.map(
                            (collection) {
                              return CollectionListTile(
                                collection: collection,
                                onRemoveNote: () {
                                  final collectionTitle =
                                      "'${collection.name}'";
                                  // final context = this.context;
                                  UiUtils.showProceedDialog(
                                    title: 'Remove note from collection?',
                                    message: 'You are about to this note from'
                                        ' $collectionTitle.'
                                        '\n\nAre you sure you want to proceed?',
                                    context: context,
                                    onYes: () {
                                      context.pop();
                                      removeFromCollection(
                                        collection,
                                      );
                                    },
                                    onNo: () {
                                      context.pop();
                                    },
                                  );
                                },
                              );
                            },
                          ).toList(),
                        )
                      ];
                      if (collections case []) {
                        children.add(
                          const Center(
                            child: NoCollectionsMessage(),
                          ),
                        );
                      }
                      return Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                        ),
                        child: Stack(
                          children: children,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final store = await db.store;
            store.box<NoteCollectionEntity>().getAll().forEach(
              (element) {
                note.collections
                  ..add(
                    element,
                  )
                  ..applyToDb();
              },
            );
            bloc.add(
              UpdateNoteEvent(
                note: note,
              ),
            );
          },
        ),
      ),
    );
  }
}
