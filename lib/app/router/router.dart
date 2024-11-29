import 'package:go_router/go_router.dart';
import 'package:note_maker/app/app_navigator_observer.dart';
import 'package:note_maker/views/home/route/route.dart';
import 'package:note_maker/views/home/view.dart';

class AppRouter {
  AppRouter._();

  String get path {
    return router.routeInformationProvider.value.uri.path;
  }

  final router = GoRouter(
    initialLocation: HomePage.path,
    routes: $appRoutes,
    observers: [
      AppNavigatorObserver(),
    ],
    debugLogDiagnostics: true,
  );

  static final _instance = AppRouter._();

  factory AppRouter() {
    return _instance;
  }
}
