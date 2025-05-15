import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:note_maker/core/constants/http.dart';
import 'package:note_maker/data/services/mixins/local_db.dart';
import 'package:note_maker/models/note/model.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:note_maker/objectbox.g.dart';
import 'package:note_maker/services/env_var_loader.dart';
import 'package:note_maker/services/session_manager.dart';
import 'package:note_maker/utils/extensions/base_response.dart';

class EditNoteRepository with LocalDBServiceMixin {
  final _env = EnvVarLoader();
  final _sessionManager = SessionManager();

  Uri? get _notesUrl {
    return _env.backendUrl?.replace(
      path: '/notes',
    );
  }

  Future<NoteEntity> putNote(
    NoteEntity note,
  ) async {
    final box = await noteBox;
    return note.copyWith(
      id: box.put(
        note,
      ),
    );
  }

  Future<List<NoteCollectionEntity>> getUnlinkedCollections(
    List<NoteCollectionEntity> linkedCollections,
  ) async {
    final linkedCollectionIds = linkedCollections.map(
      (element) {
        return element.id;
      },
    ).toList(
      growable: false,
    );
    final box = await noteCollectionBox;
    final query = box
        .query(
          NoteCollectionEntity_.id.notOneOf(
            linkedCollectionIds,
          ),
        )
        .build();
    final result = query.find();
    query.close();
    return result;
  }

  Future<String?> createNoteRemote(
    NoteEntity note,
  ) async {
    final url = _notesUrl;
    if (url == null) {
      return null;
    }
    final token = await _sessionManager.getAccessToken();
    if (token case null) {
      return null;
    }
    final response = await http.post(
      url,
      headers: HttpConstants.authHeaders(token),
      body: json.encode(
        {
          'title': note.title,
          'content': note.content,
        },
      ),
    );
    try {
      final decoded = json.decode(
        response.body,
      );
      switch (decoded) {
        case {
              'id': final String id,
            }
            when response.ok:
          return id;
        case _:
      }
    } catch (e) {
      // ignored
    }
    return null;
  }

  Future<String?> saveNoteRemote(
    NoteEntity note,
  ) async {
    final id = note.remoteId;
    if (id == null) {
      return null;
    }
    final url = _notesUrl;
    if (url == null) {
      return null;
    }
    final token = await _sessionManager.getAccessToken();
    if (token case null) {
      return null;
    }
    final response = await http.put(
      url.replace(
        path: '${url.path}/$id',
      ),
      headers: HttpConstants.authHeaders(token),
      body: json.encode(
        {
          'title': note.title,
          'content': note.content,
        },
      ),
    );
    try {
      final decoded = json.decode(
        response.body,
      );
      switch (decoded) {
        case {
              'message': final String message,
            }
            when response.ok:
          return message;
        case _:
      }
    } catch (e) {
      // ignored
    }
    return null;
  }

  Future<String?> updateNoteEmbeddings(
    NoteEntity note,
  ) async {
    final id = note.remoteId;
    if (id == null) {
      return null;
    }
    final url = _notesUrl;
    if (url == null) {
      return null;
    }
    final token = await _sessionManager.getAccessToken();
    if (token case null) {
      return null;
    }
    final response = await http.post(
      url.replace(
        path: '${url.path}/$id/embed',
      ),
      headers: HttpConstants.authHeaders(token),
      body: json.encode(
        {
          'title': note.title,
          'content': note.contentAsText,
        },
      ),
    );
    try {
      final decoded = json.decode(
        response.body,
      );
      switch (decoded) {
        case {
              'json': final String json,
            }
            when response.ok:
          return json;
        case _:
      }
    } catch (e) {
      // ignored
    }
    return null;
  }
}
