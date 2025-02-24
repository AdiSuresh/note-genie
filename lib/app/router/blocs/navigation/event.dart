enum NavigationEventType {
  init,
  pop,
  push,
  remove,
  replace,
}

class NavigationEvent {
  final NavigationEventType type;
  final String newPath;

  const NavigationEvent({
    required this.type,
    required this.newPath,
  });

  @override
  String toString() {
    final props = {
      'type': type.name,
      'newPath': newPath,
    };
    return '$runtimeType($props)';
  }
}
