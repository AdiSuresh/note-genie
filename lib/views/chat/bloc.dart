import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/models/chat/model.dart';
import 'package:note_maker/models/chat_message/model.dart';
import 'package:note_maker/services/env_var_loader.dart';
import 'package:note_maker/utils/extensions/base_response.dart';
import 'package:note_maker/views/chat/event.dart';
import 'package:note_maker/views/chat/repository.dart';
import 'package:note_maker/views/chat/state/state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  static final logger = AppLogger(
    ChatBloc,
  );

  final ChatPageRepository repository;

  final _env = EnvVarLoader();

  IdleState get idleState {
    return switch (state) {
      IdleState state => state,
      NonIdleState(
        :final previousState,
      ) =>
        previousState,
    };
  }

  ChatBloc(
    super.initialState, {
    required this.repository,
  }) {
    on<InitEvent>(
      (event, emit) {},
    );
    on<LoadAllChatsEvent>(
      (event, emit) {
        final url = switch (_env.backendUrl) {
          final Uri url => url.replace(
              path: '/chats',
            ),
          _ => null,
        };
        if (url == null) {
          return;
        }
        switch (state) {
          case final IdleState state:
            final response = repository.fetchAllChats();
            emit(
              state.copyWith(
                allChats: response,
              ),
            );
          case _:
        }
      },
    );
    on<LoadChatEvent>(
      (event, emit) async {
        if (event.id case null) {
          switch (state) {
            case final IdleState state:
              emit(
                state.copyWith(
                  chat: Future.value(
                    ChatModel.empty(),
                  ),
                ),
              );
            case _:
          }
          return;
        }
        final url = switch (_env.backendUrl) {
          final Uri url => url.replace(
              path: '/chats',
            ),
          _ => null,
        };
        if (url == null) {
          return;
        }
        switch (state) {
          case final IdleState _:
          case _:
        }
      },
    );
    on<SendMessageEvent>(
      (event, emit) async {
        if (event.message.isEmpty) {
          return;
        }
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
        switch (state) {
          case final IdleState state:
            final currentChat = await state.chat;
            final chat = currentChat.copyWith(
              messages: [
                ...currentChat.messages,
                ChatMessage(
                  data: event.message,
                  role: MessengerType.user,
                ),
              ],
            );
            emit(
              state.copyWith(
                chat: Future.value(
                  chat,
                ),
              ),
            );
          case _:
            return;
        }
        logger.i('added user message');
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
            final currentChat = (await previousState.chat);
            final chat = currentChat.copyWith(
              messages: [
                ...currentChat.messages,
                currentState.message,
              ],
            );
            final updatedIdleState = previousState.copyWith(
              chat: Future.value(
                chat,
              ),
            );
            emit(
              currentState.copyWith(
                previousState: updatedIdleState,
              ),
            );
            final chunks = <String>[];
            final index = chat.messages.length - 1;
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
                  chat.messages[index] = message;
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
          case _:
        }
        client.close();
      },
    );
    on<UpdateButtonVisibilityEvent>(
      (event, emit) {
        final idleState = switch (state) {
          final IdleState state => state,
          final NonIdleState state => state.previousState,
          // _ => null,
        };
        // if (idleState == null) {
        //   return;
        // }
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
            // _ => null,
          };
          // if (nextState == null) {
          //   return;
          // }
          emit(
            nextState,
          );
        }
      },
    );
  }
}
