import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/views/home/bloc.dart';
import 'package:note_maker/views/home/state/state.dart';
import 'package:note_maker/widgets/custom_animated_switcher.dart';

class HomeFab extends StatelessWidget {
  final VoidCallback onPressed;

  const HomeFab({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: context.watch<HomeBloc>(),
      buildWhen: (previous, current) {
        switch ((previous, current)) {
          case (final IdleState previous, final IdleState current):
            return previous.showNotes != current.showNotes;
          case _:
        }
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        final child = switch (state) {
          IdleState() => () {
              return FloatingActionButton(
                onPressed: onPressed,
                child: const Icon(
                  Icons.add,
                ),
              );
            }(),
          _ => const SizedBox(),
        };
        return CustomAnimatedSwitcher(
          child: child,
        );
      },
    );
  }
}
