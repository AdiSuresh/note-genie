import 'dart:convert';

import 'package:note_maker/app/logger.dart';
import 'package:note_maker/core/constants/http.dart';
import 'package:note_maker/models/chat/model.dart';
import 'package:note_maker/models/chat_message/model.dart';
import 'package:note_maker/services/env_var_loader.dart';
import 'package:http/http.dart' as http;
import 'package:note_maker/services/token_manager.dart';
import 'package:note_maker/utils/extensions/base_response.dart';

class ChatPageRepository {
  static final logger = AppLogger(
    ChatPageRepository,
  );

  final _env = EnvVarLoader();
  final _tokenManager = TokenManager();

  ChatPageRepository();

  Uri? get _chatsUrl {
    return _env.backendUrl?.replace(
      path: '/chats',
    );
  }

  Future<List<ChatModel>> fetchAllChats() async {
    final url = _chatsUrl;
    if (url == null) {
      return [];
    }
    final token = await _tokenManager.getAccessToken();
    if (token case null) {
      return [];
    }
    final response = await http.get(
      url,
      headers: HttpConstants.authHeaders(
        token,
      ),
    );
    try {
      final decoded = json.decode(
        response.body,
      ) as List;
      logger.i(
        'decoded: $decoded',
      );
      final allChats = <ChatModel>[];
      for (final Map object in decoded) {
        logger.i(object);
        try {
          final {
            '_id': String remoteId,
            'title': String title,
          } = object;
          final chatModel = ChatModel(
            remoteId: remoteId,
            title: title,
            messages: [],
          );
          allChats.add(
            chatModel,
          );
        } catch (e) {
          logger.i(e);
        }
      }
      logger.i('allChats: $allChats');
      return allChats;
    } catch (e) {
      logger.i(e);
    }
    return [];
  }

  Future<String?> createChat() async {
    logger.i('creating chat...');
    final url = _chatsUrl;
    if (url == null) {
      return null;
    }
    final token = await _tokenManager.getAccessToken();
    if (token case null) {
      return null;
    }
    final response = await http.post(
      url,
      headers: HttpConstants.authHeaders(
        token,
      ),
      body: json.encode(
        const {},
      ),
    );
    try {
      final decoded = json.decode(
        response.body,
      );
      logger.i(
        'decoded: $decoded',
      );
      if (decoded
          case {
            'id': String id,
          }) {
        return id;
      }
    } catch (e) {
      logger.i(e);
    }
    return null;
  }

  Future<ChatModel?> fetchChat(
    String id,
  ) async {
    final url = _chatsUrl;
    if (url == null) {
      return null;
    }
    final token = await _tokenManager.getAccessToken();
    if (token case null) {
      return null;
    }
    final response = await http.get(
      url.replace(
        path: '${url.path}/$id',
      ),
      headers: HttpConstants.authHeaders(
        token,
      ),
    );
    try {
      final decoded = json.decode(
        response.body,
      );
      logger.i(
        'decoded: $decoded',
      );
      if (decoded
          case {
            '_id': String id,
            'title': String title,
            'messages': List messageObjects,
          }) {
        final messages = <ChatMessage>[];
        for (final object in messageObjects) {
          if (object
              case {
                'data': String data,
                'role': String role,
                'timestamp': String timestamp,
              }) {
            final type = switch (role) {
              'user' => MessengerType.user,
              'bot' => MessengerType.bot,
              _ => null,
            };
            if (type == null) {
              continue;
            }
            messages.add(
              ChatMessage(
                data: data,
                role: type,
                timestamp: DateTime.tryParse(
                  timestamp,
                ),
              ),
            );
          }
        }
        return ChatModel(
          remoteId: id,
          title: title,
          messages: messages,
        );
      }
      return null;
    } catch (e) {
      logger.i(e);
    }
    return null;
  }

  Future<bool?> renameChat(
    String id,
    String title,
  ) async {
    final url = _chatsUrl;
    if (url == null) {
      return null;
    }
    final token = await _tokenManager.getAccessToken();
    if (token case null) {
      return null;
    }
    final response = await http.put(
      url.replace(
        path: '${url.path}/$id',
      ),
      headers: HttpConstants.authHeaders(
        token,
      ),
      body: json.encode(
        {
          'title': title,
        },
      ),
    );
    return response.ok;
  }

  Future<bool?> deleteChat(
    String id,
  ) async {
    final url = _chatsUrl;
    if (url == null) {
      return null;
    }
    final token = await _tokenManager.getAccessToken();
    if (token case null) {
      return null;
    }
    final response = await http.delete(
      url.replace(
        path: '${url.path}/$id',
      ),
      headers: HttpConstants.authHeaders(
        token,
      ),
    );
    return response.ok;
  }
}
