abstract class ModelBase {
  final int? id;

  const ModelBase({
    this.id,
  });

  Map<String, dynamic> toJson();
}
