import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/app/router/extra_variable/bloc.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/utils/ui_utils.dart';
import 'package:note_maker/utils/text_input_validation/validators.dart';
import 'package:note_maker/views/edit_note/view.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/views/home/bloc.dart';
import 'package:note_maker/views/home/event.dart';
import 'package:note_maker/views/home/state/state.dart';
import 'package:note_maker/views/home/widgets/collection_list_tile.dart';
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

  NoteCollection? currentCollection;

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
          (data) {
            logger.i(
              'changes detected in notes',
            );
            bloc.add(
              UpdateNotesEvent(
                notes: data,
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
      validator: Validators.nonEmptyFieldValidator,
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
      validator: Validators.nonEmptyFieldValidator,
      formKey: collectionNameFormKey,
    );
    noteCollectionsSub?.resume();
  }

  int get pageIndex {
    return switch (bloc.state.showNotes) {
      true => 0,
      _ => 1,
    };
  }

  String get pageTitle {
    return switch (bloc.state.showNotes) {
      true => 'Notes',
      _ => 'Collections',
    };
  }

  @override
  Widget build(BuildContext context) {
    IndexedStack(
      index: pageIndex,
      children: [
        // notes widget
        // collections widget
      ],
    );
    final tabs = [
      const Icon(
        Icons.folder,
      ),
      Transform.flip(
        flipX: true,
        child: Transform.rotate(
          angle: -pi / 2,
          child: const Icon(
            Icons.note,
          ),
        ),
      ),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DefaultTabController(
              length: 2,
              child: TabBar(
                tabAlignment: TabAlignment.center,
                indicator: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(15),
                ),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorPadding: EdgeInsets.zero,
                labelPadding: EdgeInsets.zero,
                automaticIndicatorColorAdjustment: false,
                isScrollable: true,
                tabs: tabs,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15).copyWith(
                bottom: 7.5,
              ),
              child: BlocBuilder<HomeBloc, HomeState>(
                bloc: context.watch<HomeBloc>(),
                buildWhen: (previous, current) {
                  return previous.showNotes != current.showNotes;
                },
                builder: (context, state) {
                  final tabs = [
                    const Icon(
                      Icons.folder,
                    ),
                    Transform.flip(
                      flipX: true,
                      child: Transform.rotate(
                        angle: -pi / 2,
                        child: const Icon(
                          Icons.note,
                        ),
                      ),
                    ),
                  ];
                  final icon = switch (state.showNotes) {
                    true => const Icon(
                        Icons.folder,
                      ),
                    _ => Transform.flip(
                        flipX: true,
                        child: Transform.rotate(
                          angle: -pi / 2,
                          child: const Icon(
                            Icons.note,
                          ),
                        ),
                      ),
                  };
                  final tabName = switch (state.showNotes) {
                    true => 'collections',
                    _ => 'notes',
                  };
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pageTitle,
                        style: context.themeData.textTheme.titleLarge,
                      ),
                      Tooltip(
                        message: 'View $tabName',
                        child: CollectionListTile(
                          onTap: () {
                            bloc.add(
                              const SwithViewEvent(),
                            );
                          },
                          child: icon,
                        ),
                      ),
                      Expanded(
                        child: DefaultTabController(
                          length: 2,
                          child: TabBar(
                            indicator: BoxDecoration(
                              color: Colors.lightBlue,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            indicatorSize: TabBarIndicatorSize.label,
                            indicatorPadding: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                            labelPadding: EdgeInsets.zero,
                            tabs: tabs,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
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
                        'Loading...',
                      ),
                    ),
                  );
                }
                final collections = state.noteCollections;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 7.5,
                    horizontal: 15,
                  ),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
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
                            CollectionListTile(
                              key: GlobalObjectKey(
                                collection,
                              ),
                              onTap: () {
                                bloc.add(
                                  ViewCollectionEvent(
                                    collection: collection,
                                  ),
                                );
                                logger.i('scroll to collection');
                                return;
                                editCollectionName(
                                  collection,
                                );
                              },
                              child: Text(
                                collection.name,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
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
                              EditNote.path,
                            );
                            notesSub?.resume();
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
            EditNote.path,
          );
          notesSub?.resume();
        },
        tooltip: 'Add note',
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
