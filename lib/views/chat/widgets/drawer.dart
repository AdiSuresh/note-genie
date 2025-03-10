import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/views/chat/bloc.dart';
import 'package:note_maker/views/chat/state/state.dart';

class ChatPageDrawer extends StatelessWidget {
  const ChatPageDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Scaffold.of(context);
    return Drawer(
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
                  Scaffold.of(context).closeDrawer();
                },
                icon: Icon(
                  Icons.edit_square,
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                final idleState = switch (state) {
                  IdleState() => state,
                  NonIdleState(
                    :final previousState,
                  ) =>
                    previousState,
                  _ => null
                };
                if (idleState == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (idleState.allChats case []) {
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
                    idleState.allChats.length,
                    (index) {
                      return ListTile(
                        title: Text(
                          idleState.allChats[index].title,
                          style: context.themeData.textTheme.titleMedium,
                        ),
                        onTap: () {
                          Scaffold.of(context).closeDrawer();
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
