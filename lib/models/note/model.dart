import 'dart:convert';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:note_maker/models/base_entity.dart';
import 'package:note_maker/models/note_collection/model.dart';
import 'package:objectbox/objectbox.dart';

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

@Entity()
@CopyWith()
class NoteEntity implements BaseEntity {
  @Id()
  @override
  int id = BaseEntity.idPlaceholder;

  final String title;

  final String content;

  @Backlink(
    'notes',
  )
  final ToMany<NoteCollectionEntity> collections;

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
    required this.collections,
  });

  factory NoteEntity.empty() {
    return NoteEntity(
      title: 'Untitled',
      content: '',
      collections: ToMany<NoteCollectionEntity>(),
    );
  }

  String get contentAsText {
    try {
      return Document.fromJson(
        contentAsJson,
      ).toPlainText().trim();
    } catch (e) {
      return '';
    }
  }
}
