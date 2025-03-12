import 'dart:convert';

import 'package:note_maker/app/logger.dart';
import 'package:note_maker/models/chat/model.dart';
import 'package:note_maker/services/env_var_loader.dart';
import 'package:http/http.dart' as http;

class ChatPageRepository {
  static final logger = AppLogger(
    ChatPageRepository,
  );

  final _env = EnvVarLoader();

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
    final response = await http.get(
      url,
    );
    try {
      final decoded = json.decode(
        response.body,
      );
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
}
