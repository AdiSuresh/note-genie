import 'package:note_maker/app/router/navigation/event.dart';

class NavigationState {
  final NavigationEvent? event;
  final String currentPath;

  NavigationState({
    this.event,
    required this.currentPath,
  });
}
