import 'package:go_router/go_router.dart';
import 'package:note_maker/app/app_navigator_observer.dart';
import 'package:note_maker/views/home/route/route.dart';
import 'package:note_maker/views/home/view.dart';

class AppRouter {
  static final _instance = AppRouter._();

  final router = GoRouter(
    initialLocation: HomePage.path,
    routes: $appRoutes,
    observers: [
      AppNavigatorObserver(),
    ],
    debugLogDiagnostics: true,
  );

  AppRouter._();

  factory AppRouter() {
    return _instance;
  }

  String get path {
    return router.routeInformationProvider.value.uri.path;
  }
}
