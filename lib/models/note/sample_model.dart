import 'package:objectbox/objectbox.dart' as ob;

@ob.Entity()
class SampleModel {
  @ob.Id(
    assignable: true,
  )
  final int id;
  final String name;
  final String dob;

  SampleModel({
    required this.id,
    required this.name,
    required this.dob,
  });
}
