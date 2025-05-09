import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/views/auth/bloc.dart';
import 'package:note_maker/views/auth/state/state.dart';

class AuthPagePopScope extends StatelessWidget {
  final Widget child;

  const AuthPagePopScope({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AuthPageBloc>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        if (bloc.state case NonIdleState()) {
          return;
        }
        if (context.mounted) {
          context.pop(
            result,
          );
        }
      },
      child: child,
    );
  }
}
