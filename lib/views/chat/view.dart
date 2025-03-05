import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/models/chat/model.dart';
import 'package:note_maker/models/chat_message/model.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/utils/extensions/scroll_controller.dart';
import 'package:note_maker/utils/ui_utils.dart';
import 'package:note_maker/views/chat/bloc.dart';
import 'package:note_maker/views/chat/event.dart';
import 'package:note_maker/views/chat/state/state.dart';
import 'package:note_maker/views/chat/widgets/chat_bubble/wrapper.dart';
import 'package:note_maker/widgets/pulsing_dot_indicator.dart';
import 'package:note_maker/views/chat/widgets/new_chat_placeholder.dart';
import 'package:note_maker/views/chat/widgets/page_title.dart';
import 'package:note_maker/views/chat/widgets/scroll_to_bottom_button.dart';
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

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  static final logger = AppLogger(
    ChatPage,
  );

  final textCtrl = TextEditingController();
  final scrollCtrl = ScrollController();

  final textFocus = FocusNode(
    canRequestFocus: false,
  );

  late final StreamSubscription<ChatState> stateSub;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final drawerKey = GlobalKey<DrawerControllerState>();
  final chatBubbleKey = GlobalKey();

  ChatBloc get bloc => context.read<ChatBloc>();

  double get cacheExtent {
    return MediaQuery.of(context).size.height * 1.5;
  }

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

  var pointerDown = false;

  void scrollToBottom() {
    switch (chatBubbleKey.currentContext) {
      case final BuildContext context when context.mounted:
        Scrollable.ensureVisible(
          context,
          alignment: 1.0,
          duration: const Duration(
            milliseconds: 125,
          ),
          curve: Curves.ease,
        );
      case _:
    }
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
      key: scaffoldKey,
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          UiUtils.dismissKeyboard();
        }
      },
      body: Column(
        children: [
          AppBarWrapper(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    scaffoldKey.currentState?.openDrawer();
                  },
                  icon: Icon(
                    Icons.menu,
                  ),
                ),
                const ChatPageTitle(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.search,
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<ChatBloc, ChatState>(
            buildWhen: (previous, current) {
              switch ((previous, current)) {
                case (
                    IdleState(
                      chat: ChatModel(
                        messages: final m1,
                      ),
                    ),
                    IdleState(
                      chat: ChatModel(
                        messages: final m2,
                      ),
                    ),
                  ):
                  if (m1.length == m2.length && m1.isNotEmpty) {
                    final result = m1.last != m2.last;
                    if (result) {
                      autoScroll();
                    }
                    return result;
                  }
                  return m1.length != m2.length;
                case (IdleState(), SendingMessageState()):
                  return true;
                case (SendingMessageState(), ReceivingMessageState()):
                  autoScroll();
                  return true;
                case (
                    ReceivingMessageState(
                      previousState: IdleState(
                        chat: ChatModel(
                          messages: final m1,
                        ),
                      ),
                    ),
                    ReceivingMessageState(
                      previousState: IdleState(
                        chat: ChatModel(
                          messages: final m2,
                        ),
                      ),
                    ),
                  ):
                  autoScroll();
                  return m1.length != m2.length;
                case (ReceivingMessageState(), IdleState()):
                  scrollToBottomWithVelocity();
                  return true;
                case _:
                  return false;
              }
            },
            builder: (context, state) {
              final idleState = state = switch (state) {
                IdleState() => state,
                MessageProcessingState(
                  :final previousState,
                ) =>
                  previousState,
              };
              final child = switch (idleState) {
                IdleState(
                  chat: ChatModel(
                    messages: [],
                  ),
                ) =>
                  NewChatPlaceholder(),
                IdleState(
                  chat: ChatModel(
                    messages: [
                      ...,
                    ],
                  ),
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
                          children: state.chat.messages.map(
                            (e) {
                              if (e
                                  case ChatMessage(
                                    role: MessengerType.bot,
                                  ) when e == idleState.chat.messages.last) {
                                return BlocBuilder<ChatBloc, ChatState>(
                                  key: chatBubbleKey,
                                  buildWhen: (previous, current) {
                                    switch ((previous, current)) {
                                      case (
                                              SendingMessageState(),
                                              ReceivingMessageState(),
                                            ) ||
                                            (
                                              ReceivingMessageState(),
                                              ReceivingMessageState(),
                                            ):
                                        return true;
                                      case _:
                                        return false;
                                    }
                                  },
                                  builder: (context, state) {
                                    switch (state) {
                                      case SendingMessageState() ||
                                            ReceivingMessageState(
                                              message: ChatMessage(
                                                data: '',
                                              ),
                                            ):
                                        return Padding(
                                          padding: const EdgeInsets.all(15).add(
                                            const EdgeInsets.symmetric(
                                              vertical: 7.5,
                                              horizontal: 15,
                                            ),
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: const PulsingDotIndicator(),
                                          ),
                                        );
                                      case ReceivingMessageState(
                                          :final message,
                                        ):
                                        return ChatBubbleWrapper(
                                          message: message,
                                        );
                                      case _:
                                        return const SizedBox();
                                    }
                                  },
                                );
                              }
                              return ChatBubbleWrapper(
                                message: e,
                              );
                            },
                          ).toList(),
                        ),
                      ),
                      ScrollToBottomButton(
                        onPressed: () {
                          scrollToBottomWithVelocity();
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
              focusNode: textFocus,
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
                    textCtrl.clear();
                    Future.delayed(
                      const Duration(
                        milliseconds: 35,
                      ),
                    ).then(
                      (value) {
                        scrollToBottomWithVelocity();
                      },
                    );
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
      drawer: Drawer(
        key: drawerKey,
        child: ListView(
          children: List.generate(
            3,
            (index) {
              return ListTile(
                title: Text(
                  'Untitled',
                  style: context.themeData.textTheme.titleMedium,
                ),
                onTap: () {
                  scaffoldKey.currentState?.closeDrawer();
                },
              );
            },
          ),
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
