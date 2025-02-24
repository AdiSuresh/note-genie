sealed class DraggableScrollableEvent {}

class UpdateVisibilityEvent extends DraggableScrollableEvent {
  final double size;

  UpdateVisibilityEvent({
    required this.size,
  });
}
