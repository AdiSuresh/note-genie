import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/app/router/blocs/extra_variable/bloc.dart';
import 'package:note_maker/data/services/objectbox_db.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/objectbox.g.dart';
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
import 'package:note_maker/widgets/collection_list_tile.dart';
import 'package:note_maker/views/home/widgets/home_fab.dart';
import 'package:note_maker/views/home/widgets/no_collections_message.dart';
import 'package:note_maker/views/home/widgets/note_list_tile.dart';
import 'package:note_maker/widgets/custom_animated_switcher.dart';
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

  static final tabIcons = [
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

  final db = ObjectBoxDB();

  final collectionNameCtrl = TextEditingController();
  final collectionNameFormKey = GlobalKey<FormState>();

  StreamSubscription<List<NoteEntity>>? notesSub;

  late final TabController tabCtrl;

  HomeBloc get bloc => context.read<HomeBloc>();

  @override
  void initState() {
    super.initState();
    logger.i('init home');
    tabCtrl = TabController(
      animationDuration: animationDuration,
      length: 2,
      vsync: this,
    );
    tabCtrl.addListener(
      handleSwitchTabEvent,
    );
    startNotesSub();
  }

  @override
  void dispose() {
    tabCtrl.removeListener(
      handleSwitchTabEvent,
    );
    tabCtrl.dispose();
    stopNotesSub();
    logger.i(
      'disposing',
    );
    collectionNameCtrl.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void handleSwitchTabEvent() {
    if (mounted) {
      bloc.add(
        SwitchTabEvent(
          index: tabCtrl.index,
        ),
      );
    }
  }

  Future<void> startNotesSub() async {
    stopNotesSub();
    final store = await db.store;
    final builder = store.box<NoteEntity>().query();
    switch (bloc.state.currentCollection) {
      case NoteCollectionEntity c when c.id > 0:
        builder.backlinkMany(
          NoteCollectionEntity_.notes,
          NoteCollectionEntity_.id.equals(
            c.id,
          ),
        );
      case _:
    }
    notesSub = builder
        .watch(
          triggerImmediately: true,
        )
        .map(
          (query) => query.find(),
        )
        .listen(
      (notes) {
        logger.i(
          'changes detected in notes',
        );
        bloc.add(
          UpdateNotesEvent(
            notes: notes,
          ),
        );
      },
    );
  }

  void stopNotesSub() {
    notesSub?.cancel();
    notesSub = null;
  }

  Future<void> putCollection(
    NoteCollectionEntity collection,
  ) async {
    collectionNameCtrl.clear();
    final title = switch (collection) {
      NoteCollectionEntity(id: 0) => () {
          return 'New collection';
        },
      NoteCollectionEntity(:final name) => () {
          collectionNameCtrl
            ..text = name
            ..selection = TextSelection(
              baseOffset: 0,
              extentOffset: name.length,
            );
          return 'Edit title';
        },
    }();
    await UiUtils.showEditTitleDialog(
      title: title,
      context: context,
      titleCtrl: collectionNameCtrl,
      onOk: () async {
        if (collectionNameFormKey.currentState?.validate() case true) {
          final store = await db.store;
          store.box<NoteCollectionEntity>().put(
                collection.copyWith(
                  name: collectionNameCtrl.text.trim(),
                ),
              );
          if (mounted) {
            context.pop();
          }
        }
      },
      onCancel: () {
        context.pop();
      },
      validator: Validators.nonEmptyFieldValidator,
      formKey: collectionNameFormKey,
    );
  }

  Future<void> deleteCollection(
    NoteCollectionEntity collection,
  ) async {
    final deleted = await db.store.then(
      (value) {
        return value.box<NoteCollectionEntity>().remove(
              collection.id,
            );
      },
    );
    final title = "'${collection.name}'";
    final content = switch (deleted) {
      true => '$title was deleted successfully',
      _ => 'Could not delete $title',
    };
    if (mounted) {
      UiUtils.showSnackbar(
        context,
        content: content,
      );
    }
  }

  StreamSubscription<List<NoteCollectionEntity>>? listener;

  void fabOnPressed() async {
    switch (tabCtrl.index) {
      case 0:
        notesSub?.pause();
        context.extra = switch (bloc.state.currentCollection) {
          final NoteCollectionEntity collection => NoteEntity.empty()
            ..collections.add(
              collection,
            ),
          _ => null,
        };
        await context.push(
          EditNote.path,
        );
        notesSub?.resume();
        startNotesSub();
      case 1:
        putCollection(
          NoteCollectionEntity.untitled(),
        );
      case _:
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bloc = context.watch<HomeBloc>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15).copyWith(
                bottom: 7.5,
              ),
              child: Row(
                children: [
                  BlocBuilder<HomeBloc, HomeState>(
                    bloc: bloc,
                    buildWhen: (previous, current) {
                      return previous.showNotes != current.showNotes;
                    },
                    builder: (context, state) {
                      return Text(
                        state.pageTitle,
                        style: context.themeData.textTheme.titleLarge,
                      );
                    },
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
                              tabs: tabIcons.map(
                                (e) {
                                  return Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: e,
                                  );
                                },
                              ).toList(),
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
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: tabCtrl,
                children: [
                  Column(
                    children: [
                      BlocBuilder<HomeBloc, HomeState>(
                        bloc: bloc,
                        buildWhen: (prev, curr) {
                          final result = [
                            prev.noteCollections != curr.noteCollections,
                            prev.currentCollection != curr.currentCollection,
                          ].or();
                          return result;
                        },
                        builder: (context, state) {
                          // if (state.noteCollectionsSub == null) {
                          //   return const Center(
                          //     child: Text(
                          //       'Loading...',
                          //     ),
                          //   );
                          // }
                          const verticalPadding = EdgeInsets.symmetric(
                            vertical: 7.5,
                          );
                          final collections = state.noteCollections;
                          final scrollView = switch (collections) {
                            [] => const NoCollectionsMessage(),
                            _ => SingleChildScrollView(
                                key: const PageStorageKey(
                                  'note-collections-list-1',
                                ),
                                padding: verticalPadding,
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: collections.map(
                                    (collection) {
                                      return Builder(
                                        key: GlobalObjectKey(
                                          collection,
                                        ),
                                        builder: (context) {
                                          var padding =
                                              const EdgeInsets.symmetric(
                                            horizontal: 7.5,
                                          );
                                          if (collection == collections.first) {
                                            padding = padding.copyWith(
                                              left: 15,
                                            );
                                          }
                                          final selected = collection ==
                                              state.currentCollection;
                                          final scale = selected ? 1.05 : 1.0;
                                          final borderColor =
                                              switch (selected) {
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
                                              transformAlignment:
                                                  Alignment.center,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: borderColor,
                                                  strokeAlign: BorderSide
                                                      .strokeAlignOutside,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  15,
                                                ),
                                              ),
                                              child: CollectionChip(
                                                onTap: () {
                                                  bloc.add(
                                                    ToggleCollectionEvent(
                                                      collection: collection,
                                                    ),
                                                  );
                                                  startNotesSub();
                                                },
                                                child: Text(
                                                  collection.name,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                          };
                          return Row(
                            children: [
                              Expanded(
                                child: scrollView,
                              ),
                              Padding(
                                padding: verticalPadding.copyWith(
                                  left: 7.5,
                                  right: 15,
                                ),
                                child: CollectionChip(
                                  onTap: () {
                                    putCollection(
                                      NoteCollectionEntity.untitled(),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.create_new_folder,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      Expanded(
                        child: BlocBuilder<HomeBloc, HomeState>(
                          bloc: bloc,
                          buildWhen: (previous, current) {
                            return previous.notes != current.notes;
                          },
                          builder: (context, state) {
                            final key = switch (state.currentCollection) {
                              null => const ValueKey(
                                  'notes-list-switcher',
                                ),
                              final c => ObjectKey(
                                  c,
                                ),
                            };
                            return CustomAnimatedSwitcher(
                              child: Builder(
                                key: key,
                                builder: (context) {
                                  if (notesSub == null) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  final notes = state.notes;
                                  if (notes.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'No notes yet',
                                      ),
                                    );
                                  }
                                  return ListView(
                                    key: PageStorageKey(
                                      state.currentCollection,
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
                                            startNotesSub();
                                          },
                                        ),
                                      const EmptyFooter(),
                                    ],
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  BlocBuilder<HomeBloc, HomeState>(
                    bloc: bloc,
                    buildWhen: (previous, current) {
                      return previous.noteCollections !=
                          current.noteCollections;
                    },
                    builder: (context, state) {
                      // if (noteCollectionsSub == null) {
                      //   return const Center(
                      //     child: CircularProgressIndicator(),
                      //   );
                      // }
                      final collections = state.noteCollections;
                      switch (collections) {
                        case []:
                          return const Center(
                            child: NoCollectionsMessage(),
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
                        children: collections.map(
                          (e) {
                            return Builder(
                              builder: (context) {
                                var padding = const EdgeInsets.symmetric(
                                  vertical: 7.5,
                                );
                                if (e == collections.first) {
                                  padding = padding.copyWith(
                                    top: 0,
                                  );
                                } else if (e == collections.last) {
                                  padding = padding.copyWith(
                                    bottom: 0,
                                  );
                                }
                                return Padding(
                                  padding: padding,
                                  child: CollectionListTile(
                                    collection: e,
                                    onTap: () async {
                                      tabCtrl.animateTo(
                                        0,
                                      );
                                      await Future.delayed(
                                        animationDuration,
                                      );
                                      if (state.currentCollection != e) {
                                        bloc.add(
                                          SelectCollectionEvent(
                                            collection: e,
                                          ),
                                        );
                                        startNotesSub();
                                      }
                                      final key = GlobalObjectKey(
                                        e,
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
                                    onEdit: () {
                                      putCollection(
                                        e,
                                      );
                                    },
                                    onDelete: () {
                                      final context = this.context;
                                      UiUtils.showProceedDialog(
                                        title: 'Delete collection?',
                                        message:
                                            'You are about to delete this collection.'
                                            ' Once deleted its gone forever.'
                                            '\n\nAre you sure you want to proceed?',
                                        context: context,
                                        onYes: () {
                                          context.pop();
                                          deleteCollection(
                                            e,
                                          );
                                        },
                                        onNo: () {
                                          context.pop();
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: HomeFab(
        onPressed: fabOnPressed,
      ),
    );
  }
}
