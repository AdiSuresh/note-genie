enum NavigationEventType {
  init,
  pop,
  push,
  remove,
  replace,
}

class NavigationEvent {
  final NavigationEventType type;
  final String currentPath;

  NavigationEvent({
    required this.type,
    required this.currentPath,
  });

  @override
  String toString() {
    final props = {
      'type': type,
      'currentPath': currentPath,
    };
    return '$runtimeType($props)';
  }
}
