// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_collection.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NoteCollectionCWProxy {
  NoteCollection id(int? id);

  NoteCollection name(String name);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NoteCollection(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NoteCollection(...).copyWith(id: 12, name: "My name")
  /// ````
  NoteCollection call({
    int? id,
    String? name,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNoteCollection.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNoteCollection.copyWith.fieldName(...)`
class _$NoteCollectionCWProxyImpl implements _$NoteCollectionCWProxy {
  const _$NoteCollectionCWProxyImpl(this._value);

  final NoteCollection _value;

  @override
  NoteCollection id(int? id) => this(id: id);

  @override
  NoteCollection name(String name) => this(name: name);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NoteCollection(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NoteCollection(...).copyWith(id: 12, name: "My name")
  /// ````
  NoteCollection call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
  }) {
    return NoteCollection(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
    );
  }
}

extension $NoteCollectionCopyWith on NoteCollection {
  /// Returns a callable class that can be used as follows: `instanceOfNoteCollection.copyWith(...)` or like so:`instanceOfNoteCollection.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NoteCollectionCWProxy get copyWith => _$NoteCollectionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteCollection _$NoteCollectionFromJson(Map<String, dynamic> json) =>
    NoteCollection(
      id: json['id'] as int?,
      name: json['name'] as String,
    );

Map<String, dynamic> _$NoteCollectionToJson(NoteCollection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
