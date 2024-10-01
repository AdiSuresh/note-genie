enum NavigationEventType {
  init,
  pop,
  push,
  remove,
  replace,
}

class NavigationEvent {
  final String currentPath;

  NavigationEvent({
    required this.currentPath,
  });

  @override
  String toString() {
    final props = {
      'currentPath': currentPath,
    };
    return '$runtimeType($props)';
  }
}
