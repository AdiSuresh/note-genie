import 'dart:convert';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:note_maker/models/base_entity.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:objectbox/objectbox.dart' as ob;

part 'model.g.dart';

@JsonSerializable()
@CopyWith()
class Note {
  final String title;
  final List<dynamic> content;
  final Set<int> collections;

  const Note({
    required this.title,
    required this.content,
    required this.collections,
  });

  factory Note.empty() {
    return const Note(
      title: 'Untitled',
      content: [],
      collections: {},
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json,
  ) {
    return _$NoteFromJson(
      json,
    );
  }

  String get contentAsText {
    return Document.fromJson(
      content,
    ).toPlainText().trim();
  }
}

@ob.Entity()
@CopyWith()
class NoteEntity implements BaseEntity {
  @ob.Id()
  @override
  int id = BaseEntity.idPlaceholder;

  final String title;

  final String content;

  @ob.Backlink()
  final collections = ob.ToMany<NoteCollectionEntity>();

  List<dynamic> get contentAsJson {
    var result = [];
    try {
      result = jsonDecode(
        content,
      );
    } catch (e) {
      // ignored
    }
    return result;
  }

  NoteEntity({
    this.id = BaseEntity.idPlaceholder,
    required this.title,
    required this.content,
  });

  factory NoteEntity.empty() {
    return NoteEntity(
      title: 'Untitled',
      content: '',
    );
  }

  String get contentAsText {
    return Document.fromJson(
      contentAsJson,
    ).toPlainText().trim();
  }
}
