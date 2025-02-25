import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/utils/extensions/scroll_controller.dart';
import 'package:note_maker/views/chat/bloc.dart';
import 'package:note_maker/views/chat/event.dart';
import 'package:note_maker/views/chat/state/state.dart';
import 'package:note_maker/views/chat/widgets/chat_bubble_wrapper.dart';
import 'package:note_maker/views/chat/widgets/page_title.dart';
import 'package:note_maker/widgets/app_bar_wrapper.dart';
import 'package:note_maker/widgets/custom_animated_switcher.dart';
import 'package:note_maker/widgets/dismiss_keyboard.dart';

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

  double get cacheExtent {
    return MediaQuery.of(context).size.height * 1.5;
  }

  final textCtrl = TextEditingController();
  final scrollCtrl = ScrollController();

  ChatBloc get bloc => context.read<ChatBloc>();

  @override
  void initState() {
    super.initState();
    logger.i('init state');
    scrollCtrl.addListener(
      updateButtonVisibility,
    );
  }

  @override
  void dispose() {
    scrollCtrl.removeListener(
      updateButtonVisibility,
    );
    scrollCtrl.dispose();
    super.dispose();
  }

  void updateButtonVisibility() {
    final diff = scrollCtrl.distanceFromBottom;
    bloc.add(
      UpdateButtonVisibilityEvent(
        value: diff >= 100,
      ),
    );
  }

  var showButton = true;
  var pointerDown = false;

  void scrollToBottom() {
    final maxScrollExtent = scrollCtrl.position.maxScrollExtent;
    scrollCtrl.animateTo(
      maxScrollExtent,
      duration: const Duration(
        milliseconds: 125,
      ),
      curve: Curves.ease,
    );
  }

  Future<void> scrollToBottomWithVelocity() async {
    const velocity = 5;

    while (scrollCtrl.hasClients && !pointerDown) {
      final diff = scrollCtrl.distanceFromBottom;

      if (diff == 0) {
        break;
      }

      final maxScrollExtent = scrollCtrl.position.maxScrollExtent;

      await scrollCtrl.animateTo(
        maxScrollExtent,
        duration: Duration(
          microseconds: (diff * 1000 / velocity).toInt(),
        ),
        curve: Curves.linear,
      );

      await Future.delayed(
        const Duration(
          milliseconds: 35,
        ),
      );
    }
  }

  void autoScroll() {
    final diff = scrollCtrl.distanceFromBottom;
    if (diff case > 0 && < 100 when !pointerDown) {
      scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
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
                        final result = m1.last != m2.last;
                        if (result) {
                          autoScroll();
                        }
                        return result;
                    }
                    return previous.messages.length != current.messages.length;
                }
              },
              builder: (context, state) {
                final child = switch (state) {
                  IdleState(
                    messages: [],
                  ) =>
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assistant,
                            size: 45,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            'What can I help with?',
                            style: context.themeData.textTheme.titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  IdleState(
                    messages: [
                      ...,
                    ]
                  ) =>
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Scrollbar(
                          controller: scrollCtrl,
                          thumbVisibility: true,
                          thickness: 15,
                          interactive: true,
                          radius: Radius.circular(15),
                          child: ListView(
                            controller: scrollCtrl,
                            padding: EdgeInsets.only(
                              right: 7.5,
                              bottom: 7.5,
                            ),
                            cacheExtent: cacheExtent,
                            children: state.messages.map(
                              (e) {
                                return ChatBubbleWrapper(
                                  message: e,
                                );
                              },
                            ).toList(),
                          ),
                        ),
                        BlocBuilder<ChatBloc, ChatState>(
                          builder: (context, state) {
                            return Positioned(
                              bottom: 7.5,
                              child: switch (state) {
                                IdleState(
                                  :final showButton,
                                ) =>
                                  CustomAnimatedSwitcher(
                                    child: switch (showButton) {
                                      true => ElevatedButton.icon(
                                          onPressed: () {
                                            scrollToBottomWithVelocity();
                                          },
                                          label: Icon(
                                            Icons.arrow_downward,
                                          ),
                                        ),
                                      _ => const SizedBox(),
                                    },
                                  ),
                              },
                            );
                          },
                        ),
                      ],
                    ),
                };
                return Expanded(
                  child: CustomAnimatedSwitcher(
                    child: child,
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
                  hintText: 'Ask anything',
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
                      Future.delayed(
                        const Duration(
                          milliseconds: 35,
                        ),
                      ).then(
                        (value) {
                          scrollToBottomWithVelocity();
                        },
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
    return Listener(
      onPointerDown: (event) {
        pointerDown = true;
      },
      onPointerUp: (event) {
        pointerDown = false;
      },
      child: DismissKeyboard(
        child: scaffold,
      ),
    );
  }
}
