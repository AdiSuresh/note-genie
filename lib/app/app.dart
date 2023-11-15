import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/app/logger.dart';
import 'package:note_maker/app/router/router.dart';
import 'package:note_maker/app/router/extra_variable/bloc.dart';
import 'package:note_maker/app/themes/themes.dart';
import 'package:note_maker/data/local_db.dart';

class NoteMaker extends StatefulWidget {
  const NoteMaker({
    super.key,
  });

  @override
  State<NoteMaker> createState() => _NoteMakerState();
}

class _NoteMakerState extends State<NoteMaker> {
  static final logger = AppLogger(
    NoteMaker,
  );

  @override
  void dispose() {
    LocalDatabase.instance.database.then(
      (value) {
        value.close().whenComplete(
          () {
            logger.i(
              'Local DB was closed',
            );
          },
        );
      },
    );
    super.dispose();
  }

  /* static const c = Color(
    0xFF0C0E0C,
  ); */

  @override
  Widget build(BuildContext context) {
    final defaultTheme = ThemeData(
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        elevation: 2.5,
        scrolledUnderElevation: 2.5,
        shadowColor: Colors.black,
        backgroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            return ExtraVariableBloc();
          },
        ),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        title: 'Note-maker',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: Themes.lightTheme,
        darkTheme: Themes.darkTheme,
      ),
    );
  }
}
