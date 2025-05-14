import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
final class User {
  final String email;

  const User({
    required this.email,
  });

  factory User.fromJson(
    Map<String, dynamic> json,
  ) {
    return _$UserFromJson(
      json,
    );
  }

  Map<String, dynamic> toJson() {
    return _$UserToJson(
      this,
    );
  }
}
