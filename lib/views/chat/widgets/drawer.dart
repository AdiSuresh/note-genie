import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/views/chat/bloc.dart';
import 'package:note_maker/views/chat/state/state.dart';

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
                return true;
              },
              builder: (context, state) {
                final idleState = switch (state) {
                  IdleState() => state,
                  NonIdleState(
                    :final previousState,
                  ) =>
                    previousState,
                };
                return FutureBuilder(
                  future: idleState.allChats,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final allChats = snapshot.data ?? [];
                    if (allChats case []) {
                      return Column(
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
                      );
                    }
                    return ListView(
                      children: List.generate(
                        allChats.length,
                        (index) {
                          final item = allChats[index];
                          return ListTile(
                            title: Text(
                              item.title,
                              style: context.themeData.textTheme.titleMedium,
                            ),
                            onTap: () {
                              _viewChat(
                                context,
                                id: item.remoteId,
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
