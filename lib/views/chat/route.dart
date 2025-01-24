import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/views/chat/view.dart';

class ChatRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ChatPage();
  }
}
