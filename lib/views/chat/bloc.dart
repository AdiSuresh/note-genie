import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/models/chat/model.dart';
import 'package:note_maker/models/chat_message/model.dart';
import 'package:note_maker/models/future_data/model.dart';
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
    on<LoadAllChatsEvent>(
      (event, emit) async {
        switch (state) {
          case final IdleState state:
            final allChats = state.allChats.copyWith(
              state: AsyncDataState.loading,
            );
            final nextState = state.copyWith(
              allChats: allChats,
            );
            emit(
              nextState,
            );
            try {
              final data = await repository.fetchAllChats();
              emit(
                nextState.copyWith(
                  allChats: AsyncData.initial(
                    data,
                  ),
                ),
              );
            } catch (e) {
              emit(
                state.copyWith(),
              );
            }
          case _:
        }
      },
    );
    on<LoadChatEvent>(
      (event, emit) async {
        switch ((state, event.id)) {
          case (final IdleState state, null):
            emit(
              state.copyWith(
                chat: AsyncData.initial(
                  ChatModel.empty(),
                ),
                showButton: false,
              ),
            );
          case (final IdleState state, final String id):
            final nextState = state.copyWith(
              chat: state.chat.copyWith(
                state: AsyncDataState.loading,
              ),
            );
            emit(
              nextState,
            );
            try {
              final data = await repository.fetchChat(
                id,
              );
              emit(
                nextState.copyWith(
                  chat: AsyncData.initial(
                    data!,
                  ),
                  showButton: false,
                ),
              );
            } catch (e) {
              logger.i('resetting: $e');
              emit(
                state.copyWith(),
              );
            }
          case _:
        }
      },
    );
    on<SendMessageEvent>(
      (event, emit) async {
        if (event.message.isEmpty) {
          return;
        }
        if (state case NonIdleState()) {
          return;
        }
        switch (state) {
          case IdleState(
              chat: AsyncData(
                data: ChatModel(
                  remoteId: null,
                ),
              ),
            ):
            try {
              final id = await repository.createChat();
              if (id == null) {
                throw Exception('Request failed');
              }
              if (state case final IdleState state) {
                emit(
                  state.copyWith(
                    chat: AsyncData.initial(
                      state.chat.data.copyWith(
                        remoteId: id,
                      ),
                    ),
                  ),
                );
              } else {
                throw Exception('Invalid state');
              }
            } catch (e) {
              return;
            }
          case _:
        }
        var url = switch (_env.backendUrl) {
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
            final currentChat = state.chat.data;
            url = url.replace(
              path: '${url.path}/${currentChat.remoteId}/respond',
            );
            logger.i('url: ${url.path}');
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
                chat: AsyncData.initial(
                  chat,
                ),
              ),
            );
          case _:
            return;
        }
        var context = '';
        if (state case final IdleState state) {
          final messages = state.chat.data.messages;
          if (messages case [...]) {
            context = messages
                .getRange(
                  0,
                  messages.length - 1,
                )
                .map(
                  (e) => '${e.role.name}: ${e.data}',
                )
                .join(
                  '\n',
                );
          }
        } else {
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
              'context': context,
              'message': event.message,
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
        } else {
          return;
        }
        try {
          logger.i('sending user message...');
          final response = await client.send(
            request,
          );
          logger.i('reasonPhrase: ${response.reasonPhrase}');
          logger.i('statusCode: ${response.statusCode}');
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
            final currentChat = previousState.chat.data;
            final chat = currentChat.copyWith(
              messages: [
                ...currentChat.messages,
                currentState.message,
              ],
            );
            final updatedIdleState = previousState.copyWith(
              chat: AsyncData.initial(
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
    on<RenameCurrentChatEvent>(
      (event, emit) async {
        final idleState = switch (state) {
          final IdleState state => state,
          _ => null,
        };
        if (idleState == null) {
          return;
        }
        final newTitle = event.title.trim();
        final oldTitle = idleState.chat.data.title;
        if (newTitle == oldTitle) {
          return;
        }
        final chat = idleState.chat.data.copyWith(
          title: newTitle,
        );
        final index = idleState.allChats.data.indexWhere(
          (element) {
            return element.remoteId == chat.remoteId;
          },
        );
        try {
          idleState.allChats.data[index] = chat;
        } catch (e) {
          // ignored
        }
        emit(
          idleState.copyWith(
            chat: AsyncData.initial(
              chat,
            ),
            allChats: AsyncData.initial(
              idleState.allChats.data,
            ),
          ),
        );
        switch (chat.remoteId) {
          case final String id:
            try {
              await repository.renameChat(
                id,
                newTitle,
              );
            } catch (e) {
              logger.i(
                'could not update title',
              );
            }
          case _:
        }
      },
    );
    on<DeleteCurrentChatEvent>(
      (event, emit) async {
        final idleState = switch (state) {
          final IdleState state => state,
          _ => null,
        };
        if (idleState == null) {
          return;
        }
        final chat = idleState.chat.data;
        idleState.allChats.data.removeWhere(
          (element) {
            return element.remoteId == chat.remoteId;
          },
        );
        emit(
          idleState.copyWith(
            chat: AsyncData.initial(
              ChatModel.empty(),
            ),
            allChats: AsyncData.initial(
              idleState.allChats.data,
            ),
          ),
        );
        switch (chat.remoteId) {
          case final String id:
            try {
              await repository.deleteChat(
                id,
              );
            } catch (e) {
              logger.i(
                'could not delete chat',
              );
            }
          case _:
        }
      },
    );
  }
}
