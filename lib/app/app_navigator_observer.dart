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

  void _processRoute(
    Route? route, [
    NavigationEvent Function({
      required String currentPath,
    })? eventConstructor,
  ]) {
    switch (route?.navigator?.context) {
      case final BuildContext context when context.mounted:
        final path = _getPath(
          context,
        );
        if (eventConstructor != null) {
          context.navBloc.add(
            eventConstructor.call(
              currentPath: path,
            ),
          );
        }
      case _:
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _processRoute(
      previousRoute,
      PopRouteEvent.new,
    );
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _processRoute(
      previousRoute,
      PushRouteEvent.new,
    );
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _processRoute(
      previousRoute,
      RemoveRouteEvent.new,
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _processRoute(
      newRoute,
      ReplaceRouteEvent.new,
    );
  }
}

extension on BuildContext {
  NavigationBloc get navBloc => read<NavigationBloc>();
}
