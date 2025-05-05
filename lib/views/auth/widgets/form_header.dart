import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/views/auth/bloc.dart';
import 'package:note_maker/views/auth/state.dart';

class AuthFormHeader extends StatelessWidget {
  const AuthFormHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthPageBloc, AuthPageState>(
      buildWhen: (previous, current) {
        switch (current) {
          case AuthFormState() || AuthenticatingState():
            return true;
          case _:
        }
        return false;
      },
      builder: (context, state) {
        final text = switch (state) {
          LoginFormState() => 'Login',
          RegisterFormState() => 'Register',
          AuthenticatingState(
            previousState: LoginFormState(),
          ) =>
            'Logging in...',
          AuthenticatingState(
            previousState: RegisterFormState(),
          ) =>
            'Registering...',
          _ => null,
        };
        if (text case null) {
          return const SizedBox();
        }
        return AnimatedSwitcher(
          duration: const Duration(
            milliseconds: 150,
          ),
          transitionBuilder: (child, animation) {
            final t1 = ScaleTransition(
              scale: Tween(
                begin: 0.975,
                end: 1.0,
              ).animate(
                animation,
              ),
              child: child,
            );
            final t2 = FadeTransition(
              opacity: animation,
              child: t1,
            );
            final t3 = SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              child: t2,
            );
            return t3;
          },
          child: Text(
            key: ValueKey(
              'auth-form-header-text: ($text)',
            ),
            text,
            style: context.themeData.textTheme.titleLarge,
          ),
        );
      },
    );
  }
}
