import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/views/chat/bloc.dart';
import 'package:note_maker/views/chat/state/state.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final textCtrl = TextEditingController();
  final scrollCtrl = ScrollController();

  ChatBloc get bloc => context.read<ChatBloc>();

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
            BlocBuilder<ChatBloc, ChatState>(
              buildWhen: (previous, current) {
                switch ((previous, current)) {
                  case (IdleState previous, IdleState current):
                    return previous.messages.length != current.messages.length;
                }
              },
              builder: (context, state) {
                return Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                  ),
                );
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
                    onPressed: () {},
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
