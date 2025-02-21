import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/views/chat/bloc.dart';
import 'package:note_maker/views/chat/event.dart';
import 'package:note_maker/views/chat/state/state.dart';
import 'package:note_maker/views/chat/widgets/chat_bubble_wrapper.dart';
import 'package:note_maker/views/chat/widgets/page_title.dart';
import 'package:note_maker/widgets/app_bar_wrapper.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static final logger = AppLogger(
    ChatPage,
  );

  final textCtrl = TextEditingController();
  final scrollCtrl = ScrollController();

  ChatBloc get bloc => context.read<ChatBloc>();

  @override
  void initState() {
    super.initState();
    logger.i('init state');
  }

  @override
  void dispose() {
    scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppBarWrapper(
              child: ChatPageTitle(),
            ),
            BlocBuilder<ChatBloc, ChatState>(
              buildWhen: (previous, current) {
                switch ((previous, current)) {
                  case (IdleState previous, IdleState current):
                    switch ((previous, current)) {
                      case (
                            IdleState(
                              messages: final m1,
                            ),
                            IdleState(
                              messages: final m2,
                            ),
                          )
                          when m1.length == m2.length && m1.isNotEmpty:
                        return m1.last != m2.last;
                    }
                    return previous.messages.length != current.messages.length;
                }
              },
              builder: (context, state) {
                switch (state) {
                  case IdleState():
                    return Expanded(
                      child: ListView(
                        controller: scrollCtrl,
                        children: state.messages.map(
                          (e) {
                            return ChatBubbleWrapper(
                              message: e,
                            );
                          },
                        ).toList(),
                      ),
                    );
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextField(
                controller: textCtrl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (textCtrl.text case '') {
                        return;
                      }
                      bloc.add(
                        SendMessageEvent(
                          message: textCtrl.text,
                        ),
                      );
                      textCtrl.clear();
                    },
                    icon: Icon(
                      Icons.send,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
