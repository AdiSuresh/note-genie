import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/models/chat/model.dart';
import 'package:note_maker/models/future_data/model.dart';
import 'package:note_maker/views/auth/repository.dart';
import 'package:note_maker/views/chat/bloc.dart';
import 'package:note_maker/views/chat/event.dart';
import 'package:note_maker/views/chat/repository.dart';
import 'package:note_maker/views/chat/state/state.dart';
import 'package:note_maker/views/chat/view.dart';

class ChatRoute extends GoRouteData {
  final String? id;
  final _repo = AuthPageRepository();

  ChatRoute({
    this.id,
  });

  @override
  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final isLoggedIn = await _repo.isLoggedIn;
    if (!isLoggedIn) {
      return '/auth?redirect-to=/chat';
    }
    return null;
  }

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final (chat, id) = switch ((ChatModel.empty(), state.uri.pathSegments)) {
      (final chat, ['chat', final id]) => (
          chat.copyWith(
            remoteId: id,
          ),
          id,
        ),
      (final chat, _) => (chat, null),
    };
    return BlocProvider(
      create: (context) {
        return ChatBloc(
          IdleState(
            chat: AsyncData.initial(
              chat,
            ),
            allChats: AsyncData.initial(
              [],
            ),
            showButton: false,
          ),
          repository: ChatPageRepository(),
        )..add(
            const LoadAllChatsEvent(),
          );
      },
      child: ChatPage(),
    );
  }
}
