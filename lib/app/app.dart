import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/app/router/router.dart';
import 'package:note_maker/app/router/extra_variable/bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: Colors.white,
          appBarTheme: const AppBarTheme(
            elevation: 2.5,
            scrolledUnderElevation: 2.5,
            shadowColor: Colors.black,
            backgroundColor: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.white,
        ),
      ),
    );
  }
}
