import 'package:json_annotation/json_annotation.dart';
import 'package:note_maker/models/model_base.dart';

part 'model.g.dart';

@JsonSerializable()
class NoteLink extends ModelBase {
  final int aId;
  final int bId;
  final String description;

  const NoteLink({
    super.id,
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

  @override
  Map<String, dynamic> toJson() {
    return _$NoteLinkToJson(
      this,
    );
  }
}
