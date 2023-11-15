import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/app/router/extra_variable/bloc.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/utils/ui_utils.dart';
import 'package:note_maker/views/edit_note/view.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/views/home/bloc.dart';
import 'package:note_maker/views/home/event.dart';
import 'package:note_maker/views/home/state/state.dart';
import 'package:note_maker/views/home/widgets/note_list_tile.dart';
import 'package:note_maker/widgets/empty_footer.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final logger = AppLogger(
    HomePage,
  );

  final collectionNameCtrl = TextEditingController();
  final collectionNameFormKey = GlobalKey<FormState>();

  StreamSubscription<List<NoteCollection>>? noteCollectionsSub;
  StreamSubscription<List<Note>>? notesSub;

  HomeBloc get bloc => context.read();

  @override
  void initState() {
    super.initState();
    HomeBloc.noteCollectionDao.getStream.then(
      (value) {
        noteCollectionsSub = value.listen(
          (event) {
            logger.i(
              'changes detected in note collections',
            );
            bloc.add(
              UpdateNoteCollectionsEvent(
                noteCollections: event,
              ),
            );
          },
        );
      },
    );
    HomeBloc.noteDao.getStream.then(
      (value) {
        notesSub = value.listen(
          (event) {
            logger.i(
              'changes detected in notes',
            );
            bloc.add(
              UpdateNotesEvent(
                notes: event,
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    unawaited(
      noteCollectionsSub?.cancel(),
    );
    unawaited(
      notesSub?.cancel(),
    );
    logger.i(
      'disposing',
    );
    collectionNameCtrl.dispose();
    super.dispose();
  }

  Future<void> editCollectionName(
    NoteCollection collection,
  ) async {
    noteCollectionsSub?.pause();
    collectionNameCtrl.clear();
    collectionNameCtrl.text = collection.name;
    collectionNameCtrl.selection = TextSelection(
      baseOffset: 0,
      extentOffset: collection.name.length,
    );
    await UiUtils.showEditTitleDialog(
      title: 'Edit collection name',
      context: context,
      titleCtrl: collectionNameCtrl,
      onOk: () {
        final valid = collectionNameFormKey.currentState?.validate() ?? false;
        if (!valid) {
          return;
        }
        HomeBloc.noteCollectionDao.update(
          collection.copyWith(
            name: collectionNameCtrl.text,
          ),
        );
        context.pop();
      },
      onCancel: () {
        context.pop();
      },
      validator: (value) {
        final text = value ?? '';
        if (text.isEmpty) {
          return 'This field cannot be empty';
        }
        return null;
      },
      formKey: collectionNameFormKey,
    );
    noteCollectionsSub?.resume();
  }

  Future<void> addCollection() async {
    noteCollectionsSub?.pause();
    collectionNameCtrl.clear();
    await UiUtils.showEditTitleDialog(
      title: 'New collection',
      context: context,
      titleCtrl: collectionNameCtrl,
      onOk: () {
        final valid = collectionNameFormKey.currentState?.validate() ?? false;
        if (!valid) {
          return;
        }
        HomeBloc.noteCollectionDao.add(
          NoteCollection(
            name: collectionNameCtrl.text,
          ),
        );
        context.pop();
      },
      onCancel: () {
        context.pop();
      },
      validator: (value) {
        final text = value ?? '';
        if (text.isEmpty) {
          return 'This field cannot be empty';
        }
        return null;
      },
      formKey: collectionNameFormKey,
    );
    noteCollectionsSub?.resume();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) {
                return previous.noteCollections != current.noteCollections;
              },
              builder: (context, state) {
                if (noteCollectionsSub == null) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(22.5),
                      child: Text(
                        'Loading collections...',
                      ),
                    ),
                  );
                }
                final collections = state.noteCollections;
                return Row(
                  children: [
                    Expanded(
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              if (collections.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(7.5),
                                  child: Text(
                                    'No collections yet',
                                  ),
                                ),
                              for (final collection in collections)
                                InkWell(
                                  focusColor: Colors.amber,
                                  onTap: () {
                                    editCollectionName(
                                      collection,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(7.5),
                                    child: Text(
                                      collection.name,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        addCollection();
                      },
                      icon: const Icon(
                        Icons.add,
                      ),
                    ),
                  ],
                );
              },
            ),
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) {
                return previous.notes != current.notes;
              },
              builder: (context, state) {
                if (notesSub == null) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final notes = state.notes;
                return Expanded(
                  child: ListView(
                    children: <Widget>[
                      for (final note in notes)
                        NoteListTile(
                          note: note,
                          viewNote: () async {
                            notesSub?.pause();
                            context.extra = note;
                            await context.push(
                              EditNote.routeName,
                            );
                            notesSub?.resume();
                            logger.d(
                              'push',
                            );
                          },
                        ),
                      const EmptyFooter(),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          notesSub?.pause();
          context.extra = null;
          await context.push(
            EditNote.routeName,
          );
          notesSub?.resume();
        },
        tooltip: 'Increment',
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
