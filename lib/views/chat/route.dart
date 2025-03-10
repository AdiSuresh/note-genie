import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/models/chat/model.dart';
import 'package:note_maker/views/chat/bloc.dart';
import 'package:note_maker/views/chat/event.dart';
import 'package:note_maker/views/chat/state/state.dart';
import 'package:note_maker/views/chat/view.dart';

class ChatRoute extends GoRouteData {
  final String? id;

  ChatRoute({
    this.id,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) {
    print('path: ${state.uri.pathSegments}');
    final chat = switch ((ChatModel.empty(), state.uri.pathSegments)) {
      (final chat, [_, final id]) => chat.copyWith(
          remoteId: id,
        ),
      (final chat, _) => chat,
    };
    return BlocProvider(
      create: (context) {
        return ChatBloc(
          IdleState(
            chat: chat,
            showButton: false,
            allChats: [],
          ),
        )..add(
            LoadDataEvent(
              chat: chat,
            ),
          );
      },
      child: ChatPage(),
    );
  }
}
