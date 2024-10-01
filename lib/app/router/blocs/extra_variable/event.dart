abstract class ExtraVariableEvent<T extends Object> {}

// Event to update the extra variable
class ExtraVariableUpdate<T> extends ExtraVariableEvent {
  final T extra;

  ExtraVariableUpdate({
    required this.extra,
  });
}
