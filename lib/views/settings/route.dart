import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/views/home/route/route.dart';
import 'package:note_maker/views/settings/view.dart';

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SettingsPage();
  }
}
