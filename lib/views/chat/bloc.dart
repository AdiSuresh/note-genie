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

  final _env = EnvVarLoader();

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
              state.copyWith(
                messages: [
                  ...state.messages,
                  ChatMessage(
                    data: event.message,
                    role: MessengerType.user,
                  ),
                ],
              ),
            );
          case _:
            return;
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
        final client = http.Client();
        if (state case final IdleState state) {
          emit(
            SendingMessageState(
              previousState: state,
              client: client,
            ),
          );
        }
        try {
          logger.i('sending user message...');
          final response = await client.send(
            request,
          );
          logger.i('response ${response.statusCode}');
          if (!response.ok) {
            throw Exception('Request failed');
          }
          if (state case final SendingMessageState state) {
            emit(
              ReceivingMessageState(
                previousState: state.previousState,
                client: client,
                response: response,
                message: ChatMessage(
                  data: '',
                  role: MessengerType.bot,
                ),
              ),
            );
          } else {
            throw Exception('Invalid state');
          }
        } catch (e) {
          logger.i('error: $e');
          if (state case final MessageProcessingState state) {
            emit(
              state.previousState,
            );
          }
          return;
        }
        logger.i('received successful response');
        switch (state) {
          case final ReceivingMessageState currentState:
            final previousState = currentState.previousState;
            final updatedIdleState = previousState.copyWith(
              messages: [
                ...previousState.messages,
                currentState.message,
              ],
            );
            emit(
              currentState.copyWith(
                previousState: updatedIdleState,
              ),
            );
            final chunks = <String>[];
            final index = updatedIdleState.messages.length - 1;
            final stream = currentState.response.stream.transform(
              utf8.decoder,
            );
            try {
              await for (final value in stream) {
                chunks.add(
                  value,
                );
                if (state case final ReceivingMessageState state) {
                  final message = state.message.copyWith(
                    data: chunks.join(),
                  );
                  state.previousState.messages[index] = message;
                  emit(
                    state.copyWith(
                      message: message,
                    ),
                  );
                }
              }
            } catch (e) {
              // ignored
            }
            logger.i('reset state');
            if (state case final MessageProcessingState state) {
              emit(
                state.previousState,
              );
            }
            logger.i(
              'message: ${currentState.previousState.messages.last.data}',
            );
          case _:
        }
        client.close();
      },
    );
    on<UpdateButtonVisibilityEvent>(
      (event, emit) {
        final idleState = switch (state) {
          final IdleState state => state,
          final MessageProcessingState state => state.previousState,
        };
        if (idleState case final state when event.value ^ state.showButton) {
          final nextIdleState = state.copyWith(
            showButton: event.value,
          );
          final nextState = switch (this.state) {
            IdleState() => nextIdleState,
            final SendingMessageState state => state.copyWith(
                previousState: nextIdleState,
              ),
            final ReceivingMessageState state => state.copyWith(
                previousState: nextIdleState,
              ),
          };
          emit(
            nextState,
          );
        }
      },
    );
  }
}
