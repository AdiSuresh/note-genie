import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/app/router/blocs/navigation/bloc.dart';
import 'package:note_maker/app/router/blocs/navigation/event.dart';

class AppNavigatorObserver extends NavigatorObserver {
  void _dispatchEvent(
    Route? route,
    NavigationEventType eventType,
  ) {
    if (route
        case Route(
          settings: RouteSettings(
            name: final String path,
          ),
          navigator: NavigatorState(
            :final context,
          ),
        ) when context.mounted) {
      context.navBloc.add(
        NavigationEvent(
          type: eventType,
          newPath: path,
        ),
      );
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _dispatchEvent(
      previousRoute,
      NavigationEventType.pop,
    );
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _dispatchEvent(
      route,
      NavigationEventType.push,
    );
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _dispatchEvent(
      previousRoute,
      NavigationEventType.remove,
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _dispatchEvent(
      newRoute,
      NavigationEventType.replace,
    );
  }
}

extension on BuildContext {
  NavigationBloc get navBloc => read<NavigationBloc>();
}
