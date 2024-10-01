import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/router/navigation/bloc.dart';
import 'package:note_maker/app/router/navigation/event.dart';

class AppNavigatorObserver extends NavigatorObserver {
  String _getPath(
    BuildContext context,
  ) {
    return GoRouter.of(context).routeInformationProvider.value.uri.path;
  }

  void _dispatchEvent(
    Route? route,
    NavigationEventType eventType,
  ) {
    print('route?.settings.name: ${route?.settings.name}');
    switch (route?.navigator?.context) {
      case final BuildContext context when context.mounted:
        final path = _getPath(
          context,
        );
        context.navBloc.add(
          NavigationEvent(
            type: eventType,
            currentPath: path,
          ),
        );
      case _:
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
      previousRoute,
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
