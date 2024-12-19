import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/app/router/blocs/extra_variable/bloc.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
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
import 'package:note_maker/views/home/widgets/home_pop_scope.dart';
import 'package:note_maker/views/home/widgets/note_collection_tab_list.dart';
import 'package:note_maker/views/home/widgets/note_list.dart';
import 'package:note_maker/widgets/note_collection_list_tile.dart';
import 'package:note_maker/views/home/widgets/home_fab.dart';
import 'package:note_maker/views/home/widgets/no_collections_message.dart';
import 'package:note_maker/widgets/custom_animated_switcher.dart';
import 'package:note_maker/widgets/selection_highlight.dart';

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
  late final StreamSubscription<HomeState> stateSub;

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
    stateSub = bloc.stream.listen(
      (state) async {
        switch (state) {
          case DeleteItemsState(
              future: final future,
            ):
            final count = await future;
            if (!mounted) {
              return;
            }
            UiUtils.showSnackBar(
              context,
              content: 'Deleted $count items',
            );
          case _:
        }
      },
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
    stateSub.cancel();
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
          final collectionUpdated = collection.copyWith(
            name: collectionNameCtrl.text.trim(),
          );
          repo.putCollection(
            collectionUpdated,
          );
          bloc.add(
            ViewNoteCollectionEvent(
              collection: collection,
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
    final scaffold = Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15).copyWith(
                bottom: 7.5,
              ),
              child: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (previous, current) {
                  return previous.runtimeType != current.runtimeType;
                },
                builder: (context, state) {
                  final child = switch (state) {
                    IdleState() => () {
                        final child = Row(
                          key: ValueKey(
                            'page-title',
                          ),
                          children: [
                            const HomePageTitle(),
                            const Spacer(),
                            Builder(
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
                            const SizedBox(
                              width: 15,
                            ),
                            IconButton(
                              onPressed: () {
                                if (tabCtrl.offset != 0) {
                                  return;
                                }
                                searchCtrl.clear();
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
                        return child;
                      },
                    final SearchState state => () {
                        final hintText = switch (state) {
                          SearchNotesState(
                            previousState: IdleState(
                              currentCollection: NoteCollectionEntity(
                                :final name,
                              ),
                            ),
                          ) =>
                            'Search in \'$name\'',
                          SearchNotesState() => 'Search notes',
                          SearchNoteCollectionsState() => 'Search collections',
                        };
                        final child = TextField(
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
                                HomeEvent event = const ToggleSearchEvent();
                                if (searchCtrl.text.isNotEmpty) {
                                  searchCtrl.text = '';
                                  event = PerformSearchEvent(
                                    query: '',
                                  );
                                }
                                bloc.add(
                                  event,
                                );
                              },
                            ),
                          ),
                        );
                        return child;
                      },
                    SelectItemsState() || DeleteItemsState() => () {
                        final child = Row(
                          key: ValueKey(
                            'selected-count',
                          ),
                          children: [
                            IconButton(
                              tooltip: 'Cancel selection',
                              onPressed: () {
                                bloc.add(
                                  const ResetStateEvent(),
                                );
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                              ),
                            ),
                            const Expanded(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(7.5),
                                  child: HomePageTitle(),
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Delete selected',
                              onPressed: () {
                                if (bloc.state
                                    case SelectNotesState(
                                      :final count,
                                    )) {
                                  final word = switch (count) {
                                    1 => 'item',
                                    _ => 'items',
                                  };
                                  UiUtils.showProceedDialog(
                                    title: 'Delete notes',
                                    message: 'Delete $count $word?',
                                    context: context,
                                    onYes: () {
                                      context.pop();
                                      bloc.add(
                                        const DeleteNotesEvent(),
                                      );
                                    },
                                    onNo: () {
                                      context.pop();
                                    },
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.delete,
                              ),
                            ),
                          ],
                        );
                        return child;
                      },
                  }();
                  return CustomAnimatedSwitcher(
                    child: child,
                  );
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (previous, current) {
                  return previous.runtimeType != current.runtimeType;
                },
                builder: (context, state) {
                  final physics = switch (state) {
                    IdleState() => null,
                    _ => NeverScrollableScrollPhysics(),
                  };
                  return TabBarView(
                    controller: tabCtrl,
                    physics: physics,
                    children: [
                      Column(
                        children: [
                          BlocBuilder<HomeBloc, HomeState>(
                            buildWhen: (previous, current) {
                              return previous.runtimeType !=
                                  current.runtimeType;
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
                              final child = switch (state) {
                                IdleState() => Row(
                                    children: [
                                      Expanded(
                                        child: NoteCollectionTabList(),
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
                                  ),
                                _ => const SizedBox(),
                              };
                              return AnimatedSwitcher(
                                duration: animationDuration,
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SizeTransition(
                                      sizeFactor: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: child,
                              );
                            },
                          ),
                          Expanded(
                            child: NoteList(),
                          ),
                        ],
                      ),
                      BlocBuilder<HomeBloc, HomeState>(
                        buildWhen: (prev, curr) {
                          switch ((prev, curr)) {
                            case (final IdleState prev, final IdleState curr):
                              return prev.noteCollections !=
                                  curr.noteCollections;
                            case (
                                final SearchNoteCollectionsState prev,
                                final SearchNoteCollectionsState curr,
                              ):
                              return prev.searchResults != curr.searchResults;
                            case (IdleState(), SearchNoteCollectionsState()):
                              return false;
                            case (
                                SelectNoteCollectionsState(),
                                SelectNoteCollectionsState(),
                              ):
                              return true;
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
                            IdleState() => state.noteCollections,
                            SearchNoteCollectionsState(
                              :final searchResults,
                            ) =>
                              searchResults,
                            SelectNoteCollectionsState(
                              :final previousState,
                            ) =>
                              previousState.noteCollections,
                            _ => null,
                          };
                          final child = switch (collections) {
                            [] => const Center(
                                child: NoCollectionsMessage(),
                              ),
                            null => const SizedBox(),
                            _ => ListView(
                                key: PageStorageKey(
                                  switch (state) {
                                    IdleState() => 'note-collection-list',
                                    SearchState(
                                      :final searchResults,
                                    ) =>
                                      searchResults,
                                    SelectItemsState() =>
                                      'note-collection-list-select',
                                    DeleteItemsState() =>
                                      'note-collection-list-delete',
                                  },
                                ),
                                children: collections.indexed.map(
                                  (element) {
                                    final (i, e) = element;
                                    final splash = switch (state) {
                                      SelectNoteCollectionsState() => false,
                                      _ => true,
                                    };
                                    final tile = NoteCollectionListTile(
                                      collection: e,
                                      splash: splash,
                                      onTap: switch (state) {
                                        IdleState() ||
                                        SearchState() =>
                                          () async {
                                            if (bloc.state case SearchState()) {
                                              bloc.add(
                                                ToggleSearchEvent(),
                                              );
                                              await Future.delayed(
                                                animationDuration,
                                              );
                                            }
                                            tabCtrl.animateTo(
                                              0,
                                            );
                                            await Future.delayed(
                                              animationDuration,
                                            );
                                            bloc.add(
                                              ViewNoteCollectionEvent(
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
                                        SelectNoteCollectionsState() => () {
                                            bloc.add(
                                              SelectNoteCollectionEvent(
                                                index: i,
                                              ),
                                            );
                                          },
                                        _ => null,
                                      },
                                      onLongPress: switch (state) {
                                        IdleState() => () {
                                            bloc.add(
                                              SelectNoteCollectionEvent(
                                                index: i,
                                              ),
                                            );
                                          },
                                        _ => null,
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
                                    );
                                    final padding = const EdgeInsets.symmetric(
                                      vertical: 7.5,
                                      horizontal: 15,
                                    );
                                    final selected = switch (state) {
                                      SelectNoteCollectionsState(
                                        :final selected,
                                      ) =>
                                        selected[i],
                                      _ => false,
                                    };
                                    return AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SizeTransition(
                                            sizeFactor: animation,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: switch (state) {
                                        DeleteNoteCollectionsState(
                                          previousState:
                                              SelectNoteCollectionsState(
                                            :final selected,
                                          ),
                                        )
                                            when selected[i] =>
                                          const SizedBox(),
                                        _ => Padding(
                                            padding: padding,
                                            child: SelectionHighlight(
                                              selected: selected,
                                              scaleFactor: 1.0125,
                                              child: tile,
                                            ),
                                          ),
                                      },
                                    );
                                  },
                                ).toList(),
                              ),
                          };
                          return CustomAnimatedSwitcher(
                            child: child,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: HomeFab(
        onPressed: fabOnPressed,
      ),
    );
    return HomePopScope(
      child: scaffold,
    );
  }
}
