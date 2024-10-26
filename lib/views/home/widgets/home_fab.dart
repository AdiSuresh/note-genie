import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/views/home/bloc.dart';
import 'package:note_maker/views/home/state/state.dart';

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
        return false;
      },
      builder: (context, state) {
        switch (state) {
          case IdleState _:
            return FloatingActionButton(
              onPressed: onPressed,
              tooltip: switch (state.showNotes) {
                true => 'Add note',
                _ => 'Add collection',
              },
              child: const Icon(
                Icons.add,
              ),
            );
          case _:
            return const SizedBox();
        }
      },
    );
  }
}
