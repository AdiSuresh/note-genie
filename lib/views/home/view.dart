import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/app/router/extra_variable/bloc.dart';
import 'package:note_maker/data/objectbox_db.dart';
import 'package:note_maker/models/note/sample_model.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/utils/extensions/iterable.dart';
import 'package:note_maker/utils/ui_utils.dart';
import 'package:note_maker/utils/text_input_validation/validators.dart';
import 'package:note_maker/views/edit_note/view.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/views/home/bloc.dart';
import 'package:note_maker/views/home/event.dart';
import 'package:note_maker/views/home/state/state.dart';
import 'package:note_maker/views/home/widgets/collection_chip.dart';
import 'package:note_maker/views/home/widgets/note_list_tile.dart';
import 'package:note_maker/widgets/empty_footer.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static final logger = AppLogger(
    HomePage,
  );

  static const animationDuration = Duration(
    milliseconds: 150,
  );

  final collectionNameCtrl = TextEditingController();
  final collectionNameFormKey = GlobalKey<FormState>();

  StreamSubscription<List<NoteCollection>>? noteCollectionsSub;
  StreamSubscription<List<Note>>? notesSub;

  HomeBloc get bloc => context.read();

  late final TabController tabCtrl;

  void setNotesSub() {}

  @override
  void initState() {
    super.initState();
    tabCtrl = TabController(
      animationDuration: animationDuration,
      length: 2,
      vsync: this,
    );
    ObjectBoxDB().store.then(
      (store) {
        notesSub = store
            .box<NoteEntity>()
            .query()
            .watch(
              triggerImmediately: true,
            )
            .map(
          (query) {
            return query.find().map(
              (e) {
                return e.data;
              },
            ).toList();
          },
        ).listen(
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
        noteCollectionsSub = store
            .box<NoteCollectionEntity>()
            .query()
            .watch(
              triggerImmediately: true,
            )
            .map(
          (query) {
            return query.find().map(
              (e) {
                return e.data;
              },
            ).toList();
          },
        ).listen(
          (event) {
            logger.i(
              'changes detected in notes',
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
  }

  @override
  void dispose() {
    tabCtrl.dispose();
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

  @override
  bool get wantKeepAlive => true;

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
        /* HomeBloc.noteCollectionDao.update(
          collection.copyWith(
            name: collectionNameCtrl.text,
          ),
        ); */
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
        /* HomeBloc.noteCollectionDao.add(
          NoteCollection(
            name: collectionNameCtrl.text,
          ),
        ); */
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
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
                  final tabIcons = [
                    Transform.flip(
                      flipX: true,
                      child: Transform.rotate(
                        angle: -pi / 2,
                        child: const Icon(
                          Icons.note,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.folder,
                    ),
                  ];
                  return Row(
                    children: [
                      Text(
                        pageTitle,
                        style: context.themeData.textTheme.titleLarge,
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Builder(
                            builder: (context) {
                              const padding = EdgeInsets.zero;
                              final borderRadius = BorderRadius.circular(
                                15,
                              );
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: borderRadius,
                                ),
                                child: TabBar(
                                  controller: tabCtrl,
                                  automaticIndicatorColorAdjustment: false,
                                  tabAlignment: TabAlignment.center,
                                  indicator: BoxDecoration(
                                    borderRadius: borderRadius,
                                    color: context.themeData.primaryColorLight,
                                  ),
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                  padding: padding,
                                  indicatorPadding: padding,
                                  labelPadding: padding,
                                  dividerColor: Colors.transparent,
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Colors.black,
                                  tabs: [
                                    ...tabIcons.map(
                                      (e) {
                                        return Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: e,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.settings,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: tabCtrl,
                children: [
                  Column(
                    children: [
                      BlocBuilder<HomeBloc, HomeState>(
                        bloc: context.watch<HomeBloc>(),
                        buildWhen: (prev, curr) {
                          final result = [
                            prev.noteCollections != curr.noteCollections,
                            prev.currentCollection != curr.currentCollection,
                          ].or();
                          return result;
                        },
                        builder: (context, state) {
                          if (noteCollectionsSub == null) {
                            return const Center(
                              child: Text(
                                'Loading...',
                              ),
                            );
                          }
                          final collections = state.noteCollections;
                          return SingleChildScrollView(
                            key: const PageStorageKey(
                              'note-collections-list-1',
                            ),
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              vertical: 7.5,
                            ),
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
                                  Builder(
                                    key: GlobalObjectKey(
                                      collection,
                                    ),
                                    builder: (context) {
                                      var padding = const EdgeInsets.symmetric(
                                        horizontal: 7.5,
                                      );
                                      if (collection == collections.first) {
                                        padding = padding.copyWith(
                                          left: 15,
                                        );
                                      } else if (collection ==
                                          collections.last) {
                                        padding = padding.copyWith(
                                          right: 15,
                                        );
                                      }
                                      final selected =
                                          collection == state.currentCollection;
                                      final scale = selected ? 1.05 : 1.0;
                                      final borderColor = switch (selected) {
                                        true => Colors.blueGrey.withOpacity(
                                            .5,
                                          ),
                                        _ => Colors.transparent,
                                      };
                                      return Padding(
                                        padding: padding,
                                        child: AnimatedContainer(
                                          duration: animationDuration,
                                          transform: Transform.scale(
                                            scale: scale,
                                          ).transform,
                                          transformAlignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: borderColor,
                                              strokeAlign:
                                                  BorderSide.strokeAlignOutside,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          child: CollectionChip(
                                            onTap: () {
                                              bloc.add(
                                                ViewCollectionEvent(
                                                  collection: collection,
                                                ),
                                              );
                                            },
                                            child: Text(
                                              collection.name,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: BlocBuilder<HomeBloc, HomeState>(
                          bloc: context.watch<HomeBloc>(),
                          buildWhen: (previous, current) {
                            return previous.notes != current.notes;
                          },
                          builder: (context, state) {
                            if (notesSub == null) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final notes = state.notes;
                            return ListView(
                              key: const PageStorageKey(
                                'notes-list',
                              ),
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
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  BlocBuilder<HomeBloc, HomeState>(
                    bloc: context.watch<HomeBloc>(),
                    buildWhen: (previous, current) {
                      return previous.noteCollections !=
                          current.noteCollections;
                    },
                    builder: (context, state) {
                      if (noteCollectionsSub == null) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final collections = state.noteCollections;
                      switch (collections) {
                        case []:
                          return const Padding(
                            padding: EdgeInsets.all(7.5),
                            child: Text(
                              'No collections yet',
                            ),
                          );
                        case _:
                      }
                      return ListView(
                        key: const PageStorageKey(
                          'note-collections-list-2',
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ).copyWith(
                          top: 7.5,
                        ),
                        children: [
                          for (final collection in collections)
                            Builder(
                              builder: (context) {
                                var padding = const EdgeInsets.symmetric(
                                  vertical: 7.5,
                                );
                                if (collection == collections.first) {
                                  padding = padding.copyWith(
                                    top: 0,
                                  );
                                } else if (collection == collections.last) {
                                  padding = padding.copyWith(
                                    bottom: 0,
                                  );
                                }
                                return Padding(
                                  padding: padding,
                                  child: CollectionChip(
                                    onTap: () async {
                                      tabCtrl.animateTo(
                                        0,
                                      );
                                      await Future.delayed(
                                        animationDuration,
                                      );
                                      if (state.currentCollection !=
                                          collection) {
                                        bloc.add(
                                          ViewCollectionEvent(
                                            collection: collection,
                                          ),
                                        );
                                      }
                                      final key = GlobalObjectKey(
                                        collection,
                                      );
                                      switch (key.currentContext) {
                                        case final BuildContext context
                                            when context.mounted:
                                          Scrollable.ensureVisible(
                                            context,
                                            alignment: .5,
                                            duration: animationDuration,
                                          );
                                        case _:
                                      }
                                    },
                                    child: Text(
                                      collection.name,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final db1 = ObjectBoxDB();
          final db2 = ObjectBoxDB();
          logger.i(db1 == db2);
          return;
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
