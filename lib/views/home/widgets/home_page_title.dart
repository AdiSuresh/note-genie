import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/views/home/bloc.dart';
import 'package:note_maker/views/home/state/state.dart';

class HomePageTitle extends StatelessWidget {
  const HomePageTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) {
        switch ((previous, current)) {
          case (IdleState previous, IdleState current):
            return previous.pageTitle != current.pageTitle;
          case (_, IdleState()):
            return true;
          case _:
        }
        return false;
      },
      builder: (context, state) {
        if (state case IdleState()) {
          return Text(
            state.pageTitle,
            style: context.themeData.textTheme.titleLarge,
          );
        }
        return const SizedBox();
      },
    );
  }
}
