import 'package:json_annotation/json_annotation.dart';

part 'note_link.g.dart';

@JsonSerializable()
class NoteLink {
  final int? id;
  final int aId;
  final int bId;
  final String description;

  const NoteLink({
    required this.id,
    required this.aId,
    required this.bId,
    required this.description,
  });

  factory NoteLink.fromJson(
    Map<String, dynamic> json,
  ) {
    return _$NoteLinkFromJson(
      json,
    );
  }

  Map<String, dynamic> toJson() {
    return _$NoteLinkToJson(
      this,
    );
  }
}
