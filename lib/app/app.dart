import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:note_maker/app/blocs/auth/bloc.dart';
import 'package:note_maker/app/blocs/auth/event.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/app/router/blocs/navigation/bloc.dart';
import 'package:note_maker/app/router/blocs/navigation/state.dart';
import 'package:note_maker/app/router/router.dart';
import 'package:note_maker/app/router/blocs/extra_variable/bloc.dart';
import 'package:note_maker/app/themes/themes.dart';

class NoteMaker extends StatefulWidget {
  const NoteMaker({
    super.key,
  });

  @override
  State<NoteMaker> createState() => _NoteMakerState();
}

class _NoteMakerState extends State<NoteMaker> {
  final logger = AppLogger(
    NoteMaker,
  );

  final router = AppRouter();

  @override
  void initState() {
    super.initState();
    logger.i('init app');
  }

  @override
  void dispose() {
    logger.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            return ExtraVariableBloc();
          },
        ),
        BlocProvider(
          create: (context) {
            return NavigationBloc(
              NavigationState(
                currentPath: router.path,
              ),
            );
          },
        ),
        BlocProvider(
          create: (context) {
            return AuthBloc()
              ..add(
                const AttemptSignInEvent(),
              );
          },
        ),
      ],
      child: SafeArea(
        child: MaterialApp.router(
          routerConfig: router.router,
          title: 'Note-maker',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.light,
          theme: Themes.lightTheme,
          darkTheme: Themes.darkTheme,
          scrollBehavior: const CustomScrollBehavior(),
          localizationsDelegates: const [
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale(
              'en',
            ),
          ],
        ),
      ),
    );
  }
}

class CustomScrollBehavior extends ScrollBehavior {
  const CustomScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
