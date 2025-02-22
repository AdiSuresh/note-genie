import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/models/chat_message/model.dart';
import 'package:note_maker/services/env_var_loader.dart';
import 'package:note_maker/utils/extensions/base_response.dart';
import 'package:note_maker/views/chat/event.dart';
import 'package:note_maker/views/chat/state/state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  static final logger = AppLogger(
    ChatBloc,
  );

  final _env = EnvVarData();

  ChatBloc(
    super.initialState,
  ) {
    on<SendMessageEvent>(
      (event, emit) async {
        if (event.message.isEmpty) {
          return;
        }
        switch (state) {
          case final IdleState state:
            emit(
              IdleState(
                messages: [
                  ...state.messages,
                  ChatMessage(
                    data: event.message,
                    role: MessengerType.user,
                  ),
                ],
              ),
            );
        }
        logger.i('added user message');
        final url = switch (_env.backendUrl) {
          final Uri url => url.replace(
              path: '/query',
            ),
          _ => null,
        };
        if (url == null) {
          return;
        }
        logger.i(url);
        final request = http.Request(
          'POST',
          url,
        )
          ..headers['Content-Type'] = 'application/json'
          ..body = json.encode(
            {
              'context': '',
              'question': event.message,
            },
          );
        logger.i('sending user message...');
        final response = await http.Client().send(
          request,
        );
        logger.i('response ${response.statusCode}');
        if (!response.ok) {
          logger.i('request failed: ${response.reasonPhrase}');
          return;
        }
        logger.i('received successful response');
        switch (state) {
          case IdleState currentState:
            final botMessage = ChatMessage(
              data: '',
              role: MessengerType.bot,
            );
            final updatedState = IdleState(
              messages: [
                ...currentState.messages,
                botMessage,
              ],
            );
            emit(
              updatedState,
            );
            final chunks = <String>[];
            final index = updatedState.messages.length - 1;
            final stream = response.stream.transform(
              utf8.decoder,
            );
            await for (final value in stream) {
              chunks.add(
                value,
              );
              final updatedMessages = List<ChatMessage>.from(
                updatedState.messages,
              );
              updatedMessages[index] = updatedMessages[index].copyWith(
                data: chunks.join(),
              );
              emit(
                IdleState(
                  messages: updatedMessages,
                ),
              );
            }
        }
      },
    );
  }
}
