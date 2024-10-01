sealed class NavigationEvent {
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

class InitEvent extends NavigationEvent {
  InitEvent({
    super.currentPath = '/',
  });
}

class PopRouteEvent extends NavigationEvent {
  PopRouteEvent({
    required super.currentPath,
  });
}

class PushRouteEvent extends NavigationEvent {
  PushRouteEvent({
    required super.currentPath,
  });
}

class RemoveRouteEvent extends NavigationEvent {
  RemoveRouteEvent({
    required super.currentPath,
  });
}

class ReplaceRouteEvent extends NavigationEvent {
  ReplaceRouteEvent({
    required super.currentPath,
  });
}
