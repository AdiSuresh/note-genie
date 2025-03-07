import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/views/chat/bloc.dart';
import 'package:note_maker/views/chat/state/state.dart';
import 'package:note_maker/widgets/custom_animated_switcher.dart';

class ScrollToBottomButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ScrollToBottomButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) {
        final s1 = switch (previous) {
          IdleState() => previous,
          NonIdleState(
            :final previousState,
          ) =>
            previousState,
          _ => null,
        };
        if (s1 == null) {
          return true;
        }
        final s2 = switch (current) {
          IdleState() => current,
          NonIdleState(
            :final previousState,
          ) =>
            previousState,
          _ => null,
        };
        if (s2 == null) {
          return true;
        }
        return s1.showButton ^ s2.showButton;
      },
      builder: (context, state) {
        final idleState = switch (state) {
          IdleState() => state,
          MessageProcessingState(
            :final previousState,
          ) =>
            previousState,
          _ => null,
        };
        if (idleState == null) {
          return const SizedBox();
        }
        return Positioned(
          bottom: 7.5,
          child: CustomAnimatedSwitcher(
            child: switch (idleState.showButton) {
              true => ElevatedButton.icon(
                  onPressed: onPressed,
                  label: Icon(
                    Icons.arrow_downward,
                  ),
                ),
              _ => const SizedBox(),
            },
          ),
        );
      },
    );
  }
}
