import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/app/router/blocs/extra_variable/bloc.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/utils/extensions/iterable.dart';
import 'package:note_maker/utils/extensions/type.dart';
import 'package:note_maker/utils/ui_utils.dart';
import 'package:note_maker/utils/text_input_validation/validators.dart';
import 'package:note_maker/views/edit_note/view.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/views/home/bloc.dart';
import 'package:note_maker/views/home/event.dart';
import 'package:note_maker/views/home/repository.dart';
import 'package:note_maker/views/home/state/state.dart';
import 'package:note_maker/views/home/widgets/collection_chip.dart';
import 'package:note_maker/views/home/widgets/home_page_title.dart';
import 'package:note_maker/widgets/collection_list_tile.dart';
import 'package:note_maker/views/home/widgets/home_fab.dart';
import 'package:note_maker/views/home/widgets/no_collections_message.dart';
import 'package:note_maker/views/home/widgets/note_list_tile.dart';
import 'package:note_maker/widgets/custom_animated_switcher.dart';
import 'package:note_maker/widgets/empty_footer.dart';

class HomePage extends StatefulWidget {
  static const path = '/';

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

  final collectionNameCtrl = TextEditingController();
  final collectionNameFormKey = GlobalKey<FormState>();

  final searchCtrl = TextEditingController();

  late final TabController tabCtrl;

  HomeBloc get bloc => context.read<HomeBloc>();
  HomeRepository get repo => context.read<HomeRepository>();

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
  }

  @override
  void dispose() {
    tabCtrl.removeListener(
      handleSwitchTabEvent,
    );
    tabCtrl.dispose();
    logger.i(
      'disposing home',
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
    UiUtils.showEditTitleDialog(
      title: title,
      context: context,
      titleCtrl: collectionNameCtrl,
      onOk: () async {
        if (collectionNameFormKey.currentState?.validate() case true) {
          repo.putCollection(
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
    final deleted = await repo.removeCollection(
      collection,
    );
    final title = "'${collection.name}'";
    final content = switch (deleted) {
      true => '$title was deleted successfully',
      _ => 'Could not delete $title',
    };
    if (mounted) {
      UiUtils.showSnackBar(
        context,
        content: content,
      );
    }
  }

  void fabOnPressed() async {
    final state = bloc.state;
    if (state is! IdleState) {
      return;
    }
    switch (tabCtrl.index) {
      case 0:
        context.extra = switch (state.currentCollection) {
          final NoteCollectionEntity collection => NoteEntity.empty()
            ..collections.add(
              collection,
            ),
          _ => null,
        };
        context.go(
          (EditNote).asRoutePath(),
        );
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
              child: BlocBuilder<HomeBloc, HomeState>(
                bloc: bloc,
                buildWhen: (previous, current) {
                  return previous.runtimeType != current.runtimeType;
                },
                builder: (context, state) {
                  switch (state) {
                    case IdleState():
                      return Row(
                        children: [
                          HomePageTitle(),
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
                                        color:
                                            context.themeData.primaryColorLight,
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
                            onPressed: () {
                              bloc.add(
                                const ToggleSearchEvent(),
                              );
                            },
                            icon: const Icon(
                              Icons.search,
                            ),
                          ),
                        ],
                      );
                    case final SearchState state:
                      final hintText = switch (state) {
                        SearchNotesState(
                          previousState: IdleState(
                            :final NoteCollectionEntity currentCollection,
                          ),
                        ) =>
                          'Search in \'${currentCollection.name}\'',
                        SearchNotesState() => 'Search notes',
                        SearchNoteCollectionsState() => 'Search collections',
                      };
                      return TextField(
                        controller: searchCtrl,
                        autofocus: true,
                        onChanged: (value) {
                          bloc.add(
                            PerformSearchEvent(
                              query: value.trim(),
                            ),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: hintText,
                          contentPadding: EdgeInsets.all(15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                            ),
                            onPressed: () {
                              if (searchCtrl.text.isNotEmpty) {
                                searchCtrl.text = '';
                                bloc.add(
                                  PerformSearchEvent(
                                    query: '',
                                  ),
                                );
                              } else {
                                bloc.add(
                                  const ToggleSearchEvent(),
                                );
                              }
                            },
                          ),
                        ),
                      );
                  }
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
                        bloc: bloc,
                        buildWhen: (prev, curr) {
                          switch ((prev, curr)) {
                            case (final IdleState prev, final IdleState curr):
                              return [
                                prev.noteCollections != curr.noteCollections,
                                prev.currentCollection !=
                                    curr.currentCollection,
                              ].or();
                            case _:
                          }
                          return prev.runtimeType != curr.runtimeType;
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
                          final data = switch (state) {
                            final IdleState state => (
                                state.noteCollections,
                                state.currentCollection,
                              ),
                            final SearchNoteCollectionsState state => (
                                state.searchResults,
                                state.previousState.currentCollection,
                              ),
                            _ => null,
                          };
                          if (data case null) {
                            return const SizedBox();
                          }
                          final (collections, currentCollection) = data;
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
                                          final selected =
                                              collection == currentCollection;
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
                            switch ((previous, current)) {
                              case (
                                  final IdleState prev,
                                  final IdleState curr,
                                ):
                                return prev.notes != curr.notes;
                              case (
                                  _,
                                  SearchNotesState(),
                                ):
                                return true;
                              case _:
                            }
                            return previous.runtimeType != current.runtimeType;
                          },
                          builder: (context, state) {
                            final data = switch (state) {
                              final IdleState state => (
                                  state.currentCollection,
                                  state.notes,
                                ),
                              final SearchNotesState state => (
                                  state.previousState.currentCollection,
                                  state.searchResults,
                                ),
                              _ => null,
                            };
                            if (data case null) {
                              return const SizedBox();
                            }
                            final (currentCollection, notes) = data;
                            final key = switch (currentCollection) {
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
                                  // if (notesSub == null) {
                                  //   return const Center(
                                  //     child: CircularProgressIndicator(),
                                  //   );
                                  // }
                                  if (notes.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'No notes yet',
                                      ),
                                    );
                                  }
                                  return ListView(
                                    key: PageStorageKey(
                                      currentCollection,
                                    ),
                                    children: <Widget>[
                                      for (final note in notes)
                                        NoteListTile(
                                          note: note,
                                          viewNote: () async {
                                            context.extra = note;
                                            context.go(
                                              (EditNote).asRoutePath(),
                                            );
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
                    buildWhen: (prev, curr) {
                      switch ((prev, curr)) {
                        case (final IdleState prev, final IdleState curr):
                          return prev.noteCollections != curr.noteCollections;
                        case _:
                      }
                      return prev.runtimeType != curr.runtimeType;
                    },
                    builder: (context, state) {
                      // if (noteCollectionsSub == null) {
                      //   return const Center(
                      //     child: CircularProgressIndicator(),
                      //   );
                      // }
                      final collections = switch (state) {
                        IdleState _ => state.noteCollections,
                        SearchState state =>
                          state.previousState.noteCollections,
                      };
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
                                      bloc.add(
                                        SelectCollectionEvent(
                                          collection: e,
                                        ),
                                      );
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
