import 'package:note_maker/models/base_entity.dart';
import 'package:objectbox/objectbox.dart' as ob;

@ob.Entity()
class SampleModel {
  @ob.Id()
  int id = BaseEntity.idPlaceholder;
  final String name;
  final String dob;

  SampleModel({
    this.id = BaseEntity.idPlaceholder,
    required this.name,
    required this.dob,
  });
}
