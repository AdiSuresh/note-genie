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

  (BuildContext, String)? _processRoute(
    Route? route,
  ) {
    switch (route?.navigator?.context) {
      case final BuildContext context when context.mounted:
        final path = _getPath(
          context,
        );
        return (context, path);
      case _:
        return null;
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    final result = _processRoute(
      previousRoute,
    );
    if (result case (final BuildContext context, final String path)) {
      context.navBloc.add(
        PopRouteEvent(
          currentPath: path,
        ),
      );
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    final result = _processRoute(
      previousRoute,
    );
    if (result case (final BuildContext context, final String path)) {
      context.navBloc.add(
        PushRouteEvent(
          currentPath: path,
        ),
      );
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    final result = _processRoute(
      previousRoute,
    );
    if (result case (final BuildContext context, final String path)) {
      context.navBloc.add(
        RemoveRouteEvent(
          currentPath: path,
        ),
      );
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    final result = _processRoute(
      newRoute,
    );
    if (result case (final BuildContext context, final String path)) {
      context.navBloc.add(
        ReplaceRouteEvent(
          currentPath: path,
        ),
      );
    }
  }
}

extension on BuildContext {
  NavigationBloc get navBloc => read<NavigationBloc>();
}
