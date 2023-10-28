import 'package:go_router/go_router.dart';
import 'package:note_maker/views/edit_note/view.dart';
import '../../views/home/view.dart';

class ConnectdAppRouter {
  ConnectdAppRouter._();

  static List<GoRoute> get routes => [
        GoRoute(
          path: '/',
          builder: (context, state) {
            return const HomePage();
          },
        ),
        GoRoute(
          path: '/edit-note',
          builder: (context, state) {
            return const EditNote();
          },
        ),
      ];

  static final router = GoRouter(
    initialLocation: '/',
    routes: routes,
  );

  static final _instance = ConnectdAppRouter._();

  factory ConnectdAppRouter() {
    return _instance;
  }
}
