import 'package:go_router/go_router.dart';
import 'package:note_maker/app/app_navigator_observer.dart';
import 'package:note_maker/views/home/route/route.dart';
import 'package:note_maker/views/home/view.dart';

class AppRouter {
  const AppRouter._();

  static String get path {
    return router.routeInformationProvider.value.uri.path;
  }

  static final routeObserver = AppNavigatorObserver();

  static final router = GoRouter(
    initialLocation: HomePage.path,
    routes: $appRoutes,
    observers: [
      routeObserver,
    ],
  );

  static const _instance = AppRouter._();

  factory AppRouter() {
    return _instance;
  }
}
