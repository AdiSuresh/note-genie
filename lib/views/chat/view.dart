import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/models/chat/model.dart';
import 'package:note_maker/models/chat_message/model.dart';
import 'package:note_maker/models/future_data/model.dart';
import 'package:note_maker/utils/extensions/scroll_controller.dart';
import 'package:note_maker/utils/ui_utils.dart';
import 'package:note_maker/views/chat/bloc.dart';
import 'package:note_maker/views/chat/event.dart';
import 'package:note_maker/views/chat/state/state.dart';
import 'package:note_maker/views/chat/widgets/chat_bubble/wrapper.dart';
import 'package:note_maker/views/chat/widgets/drawer.dart';
import 'package:note_maker/views/chat/widgets/new_chat_placeholder.dart';
import 'package:note_maker/views/chat/widgets/page_title.dart';
import 'package:note_maker/views/chat/widgets/scroll_to_bottom_button.dart';
import 'package:note_maker/widgets/app_bar_wrapper.dart';
import 'package:note_maker/widgets/custom_animated_switcher.dart';
import 'package:note_maker/widgets/dismiss_keyboard.dart';
import 'package:note_maker/widgets/three_dot_indicator.dart';

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

  final scaffoldKey = GlobalKey<ScaffoldState>();
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
    switch (scrollCtrl.position) {
      case ScrollPosition(
            :final minScrollExtent,
            :final maxScrollExtent,
          )
          when minScrollExtent == maxScrollExtent:
        return;
      case _:
    }
    final diff = scrollCtrl.findDistanceFromBottom(
      true,
    );
    bloc.add(
      UpdateButtonVisibilityEvent(
        value: diff >= 100,
      ),
    );
  }

  void preventOverscroll() {
    if (scrollCtrl.position.outOfRange) {
      final ScrollPosition(
        :maxScrollExtent,
        :minScrollExtent,
      ) = scrollCtrl.position;
      if (scrollCtrl.offset > maxScrollExtent) {
        scrollCtrl.jumpTo(
          maxScrollExtent,
        );
      } else if (scrollCtrl.offset < minScrollExtent) {
        scrollCtrl.jumpTo(
          minScrollExtent,
        );
      }
    }
  }

  var pointerDown = false;

  final titleCtrl = TextEditingController();

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

    scrollCtrl.addListener(
      preventOverscroll,
    );
    while (scrollCtrl.hasClients && !pointerDown) {
      final diff = scrollCtrl.offset.abs();

      if (diff == 0) {
        break;
      }

      await scrollCtrl.animateTo(
        0,
        duration: Duration(
          milliseconds: (diff / velocity).toInt(),
        ),
        curve: Curves.linear,
      );

      await Future.delayed(
        const Duration(
          milliseconds: 30,
        ),
      );
    }
    scrollCtrl.removeListener(
      preventOverscroll,
    );
  }

  void autoScroll() {
    final diff = scrollCtrl.findDistanceFromBottom(
      true,
    );
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
                ChatPageTitle(
                  items: [
                    (
                      'Rename',
                      () {
                        switch (bloc.state) {
                          case IdleState(
                              :final chat,
                            ):
                            titleCtrl.text = chat.data.title;
                            titleCtrl.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: titleCtrl.text.length,
                            );
                            UiUtils.showEditTitleDialog(
                              title: 'Edit title',
                              context: context,
                              titleCtrl: titleCtrl,
                              onOk: () {
                                context.pop();
                                bloc.add(
                                  RenameCurrentChatEvent(
                                    title: titleCtrl.text,
                                  ),
                                );
                              },
                              onCancel: () {
                                context.pop();
                              },
                            );
                          case _:
                        }
                      },
                    ),
                    (
                      'Delete',
                      () {
                        switch (bloc.state) {
                          case IdleState():
                            UiUtils.showProceedDialog(
                              title: 'Delete chat?',
                              message: 'You are about to delete this chat.'
                                  ' Once deleted its gone forever.'
                                  '\n\nAre you sure you want to proceed?',
                              context: context,
                              onYes: () {
                                bloc.add(
                                  const DeleteCurrentChatEvent(),
                                );
                                context.pop();
                                context.go(
                                  '/chat',
                                );
                              },
                              onNo: () {
                                context.pop();
                              },
                            );
                          case _:
                        }
                      },
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    switch (bloc.state) {
                      case final IdleState state:
                        logger.i(
                          'messages: ${state.chat.data.messages}',
                        );
                        break;
                      default:
                    }
                  },
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
                        chat: AsyncData(
                          data: ChatModel(
                            remoteId: final id1,
                          ),
                          state: final s1,
                        ),
                      ),
                      IdleState(
                        chat: AsyncData(
                          data: ChatModel(
                            remoteId: final id2,
                          ),
                          state: final s2,
                        ),
                      ),
                    )
                    when id1 != id2 || s1 != s2:
                  return true;
                case (IdleState(), SendingMessageState()):
                  return true;
                case (SendingMessageState(), ReceivingMessageState()):
                  autoScroll();
                  return true;
                case (
                    ReceivingMessageState(
                      previousState: IdleState(
                        chat: AsyncData(
                          data: ChatModel(
                            messages: final m1,
                          ),
                        ),
                      ),
                    ),
                    ReceivingMessageState(
                      previousState: IdleState(
                        chat: AsyncData(
                          data: ChatModel(
                            messages: final m2,
                          ),
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
              final idleState = switch (state) {
                IdleState() => state,
                NonIdleState(
                  :final previousState,
                ) =>
                  previousState,
              };
              final child = switch (idleState.chat) {
                AsyncData(
                  state: AsyncDataState.loading,
                ) =>
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                AsyncData(
                  data: ChatModel(
                    messages: [],
                  )
                ) =>
                  const NewChatPlaceholder(),
                AsyncData(
                  data: ChatModel(
                    :final messages,
                  )
                ) =>
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      ListView.builder(
                        controller: scrollCtrl,
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final e = messages[messages.length - 1 - index];
                          final child = switch ((state, e)) {
                            (
                              MessageProcessingState(),
                              ChatMessage(
                                role: MessengerType.bot,
                              ),
                            )
                                when e == messages.last =>
                              BlocBuilder<ChatBloc, ChatState>(
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
                                          child: const ThreeDotIndicator(),
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
                              ),
                            _ => ChatBubbleWrapper(
                                message: e,
                              ),
                          };
                          return Builder(
                            key: ValueKey(e),
                            builder: (context) {
                              return child;
                            },
                          );
                        },
                      ),
                      const Positioned(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white,
                                blurRadius: 7.5,
                                spreadRadius: 7.5,
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                          ),
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
          Container(
            padding: const EdgeInsets.all(15).copyWith(
              top: 7.5,
              bottom: 7.5,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 7.5,
                  spreadRadius: 7.5,
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: textCtrl,
                  focusNode: textFocus,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 4,
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
                const SizedBox(
                  height: 7.5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton.filled(
                      onPressed: () {},
                      icon: Icon(
                        Icons.notes,
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () {},
                      icon: Icon(
                        Icons.expand,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: ChatPageDrawer(),
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
