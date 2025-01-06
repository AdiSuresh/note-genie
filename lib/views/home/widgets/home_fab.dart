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

  String _getTitle(
    IdleState state,
  ) {
    final suffix = switch (state.showNotes) {
      true => 'note',
      _ => 'collection',
    };
    return 'Add $suffix';
  }

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
              final title = _getTitle(
                state,
              );
              final keyValue = switch (state.showNotes) {
                true => 'add-note-fab-title',
                _ => 'add-note-collection-fab-title',
              };
              return FloatingActionButton.extended(
                onPressed: onPressed,
                label: AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 150,
                  ),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axis: Axis.horizontal,
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    title,
                    key: ValueKey(
                      keyValue,
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                icon: const Icon(
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
