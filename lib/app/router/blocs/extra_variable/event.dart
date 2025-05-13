sealed class ExtraVariableEvent<T extends Object> {
  const ExtraVariableEvent();
}

/// Event for updating the extra variable.
final class UpdateVariableEvent<T extends Object>
    extends ExtraVariableEvent<T> {
  final T extra;

  const UpdateVariableEvent({
    required this.extra,
  });
}
