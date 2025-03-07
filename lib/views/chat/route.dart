import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/models/chat/model.dart';
import 'package:note_maker/views/chat/bloc.dart';
import 'package:note_maker/views/chat/event.dart';
import 'package:note_maker/views/chat/state/state.dart';
import 'package:note_maker/views/chat/view.dart';

class ChatRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (context) {
        return ChatBloc(
          IdleState(
            chat: ChatModel.empty(),
            showButton: false,
            allChats: [],
          ),
        )..add(
            const LoadDataEvent(),
          );
      },
      child: ChatPage(),
    );
  }
}
