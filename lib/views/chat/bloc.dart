import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/views/chat/event.dart';
import 'package:note_maker/views/chat/state/state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(
    super.initialState,
  );
}
