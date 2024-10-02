abstract class ExtraVariableEvent<T extends Object> {}

/// Event for updating the extra variable.
class ExtraVariableUpdate<T> extends ExtraVariableEvent {
  final T extra;

  ExtraVariableUpdate({
    required this.extra,
  });
}
