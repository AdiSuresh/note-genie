import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/utils/ui_utils.dart';
import 'package:note_maker/views/home/bloc.dart';
import 'package:note_maker/views/home/event.dart';
import 'package:note_maker/views/home/state/state.dart';

class HomePopScope extends StatelessWidget {
  final Widget child;

  const HomePopScope({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HomeBloc>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final state = bloc.state;
        switch (state) {
          case IdleState():
            break;
          case DeleteItemsState():
            return;
          case _:
            bloc.add(
              const ResetStateEvent(),
            );
            return;
        }
        final exit = await UiUtils.showProceedDialog(
          title: 'App Exit',
          message: 'Would you like to exit the app?',
          context: context,
          onYes: () {
            context.pop(
              true,
            );
          },
          onNo: () {
            context.pop(
              false,
            );
          },
        );
        if (exit case true) {
          SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}
