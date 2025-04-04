import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/models/future_data/model.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/utils/extensions/iterable.dart';
import 'package:note_maker/views/chat/bloc.dart';
import 'package:note_maker/views/chat/event.dart';
import 'package:note_maker/views/chat/state/state.dart';
import 'package:note_maker/widgets/custom_animated_switcher.dart';

class ChatPageDrawer extends StatelessWidget {
  const ChatPageDrawer({
    super.key,
  });

  void _viewChat(
    BuildContext context, {
    String? id,
  }) {
    final bloc = context.read<ChatBloc>();
    if (bloc.state case IdleState()) {
      Scaffold.of(context).closeDrawer();
      final path = switch (id) {
        null => '/chat',
        _ => '/chat/$id',
      };
      context.replace(
        path,
      );
      bloc.add(
        LoadChatEvent(
          id: id,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 7.5,
                horizontal: 15,
              ),
              child: IconButton.filled(
                onPressed: () {
                  _viewChat(
                    context,
                  );
                },
                icon: Icon(
                  Icons.edit_square,
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              buildWhen: (previous, current) {
                switch ((previous, current)) {
                  case (
                      IdleState(
                        allChats: final d1,
                      ),
                      IdleState(
                        allChats: final d2,
                      ),
                    ):
                    return [
                      d1 != d2,
                      d1.state != d2.state,
                    ].or();
                  case _:
                }
                return false;
              },
              builder: (context, state) {
                final idleState = switch (state) {
                  IdleState() => state,
                  NonIdleState(
                    :final previousState,
                  ) =>
                    previousState,
                };
                final child = switch (idleState.allChats) {
                  AsyncData(
                    state: AsyncDataState.loading,
                  ) =>
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  AsyncData(
                    data: [],
                  ) =>
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          'No chats yet',
                          style: context.themeData.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  AsyncData(
                    data: final allChats,
                  ) =>
                    ListView(
                      children: List.generate(
                        allChats.length,
                        (index) {
                          final item = allChats[index];
                          final textTheme = Theme.of(context).textTheme;
                          final controller = MenuController();
                          final tile = Builder(
                            builder: (context) {
                              Offset? menuOffset;
                              return InkWell(
                                onTap: () {
                                  _viewChat(
                                    context,
                                    id: item.remoteId,
                                  );
                                },
                                onLongPress: () {
                                  controller.open(
                                    position: menuOffset,
                                  );
                                },
                                onTapDown: (details) {
                                  menuOffset = details.localPosition;
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.title,
                                        style: textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                          return MenuAnchor(
                            controller: controller,
                            consumeOutsideTap: true,
                            style: MenuStyle(
                              backgroundColor: WidgetStateProperty.all(
                                Colors.white,
                              ),
                            ),
                            menuChildren: [
                              (
                                'Rename',
                                () {},
                              ),
                              (
                                'Delete',
                                () {},
                              ),
                            ].map(
                              (e) {
                                final (label, callback) = e;
                                return MenuItemButton(
                                  onPressed: callback,
                                  child: Text(
                                    label,
                                  ),
                                );
                              },
                            ).toList(),
                            child: tile,
                          );
                        },
                      ),
                    ),
                };
                return CustomAnimatedSwitcher(
                  child: child,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
