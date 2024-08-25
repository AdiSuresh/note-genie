abstract class BaseEntity<T extends Object> {
  final int id;

  final T data;

  BaseEntity({
    required this.id,
    required this.data,
  });
}
