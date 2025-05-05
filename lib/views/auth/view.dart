import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_maker/views/auth/bloc.dart';
import 'package:note_maker/views/auth/event.dart';
import 'package:note_maker/views/auth/state.dart';
import 'package:note_maker/views/auth/widgets/form_header.dart';
import 'package:note_maker/widgets/dismiss_keyboard.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  static const animationDuration = Duration(
    milliseconds: 150,
  );

  final formKey = GlobalKey<FormState>();

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final reEnterPasswordCtrl = TextEditingController();

  StreamSubscription<AuthPageState>? stateSub;

  AuthPageBloc get bloc => context.read<AuthPageBloc>();

  @override
  void initState() {
    super.initState();
    stateSub = bloc.stream.listen(
      onStateChange,
    );
  }

  @override
  void dispose() {
    stateSub?.cancel();
    super.dispose();
  }

  void onStateChange(
    AuthPageState state,
  ) {}

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AuthFormHeader(),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 7.5,
                ),
                child: TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    switch (value) {
                      case '':
                        return 'This field is required';
                      case String():
                        final isValid = EmailValidator.validate(
                          value,
                        );
                        if (!isValid) {
                          return 'Please enter a valid email';
                        }
                      case _:
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 7.5,
                ),
                child: TextFormField(
                  controller: passwordCtrl,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    switch (value) {
                      case '':
                        return 'This field is required';
                      case String():
                      case _:
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              BlocBuilder<AuthPageBloc, AuthPageState>(
                buildWhen: (previous, current) {
                  switch ((previous, current)) {
                    case (RegisterFormState(), _) || (_, RegisterFormState()):
                      return true;
                    case _:
                  }
                  return false;
                },
                builder: (context, state) {
                  final registerFormState = switch (state) {
                    final RegisterFormState state => state,
                    final NonIdleState state => state,
                    _ => null,
                  };
                  return AnimatedSwitcher(
                    duration: animationDuration,
                    transitionBuilder: (child, animation) {
                      final t1 = FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                      final t2 = SizeTransition(
                        sizeFactor: animation,
                        child: t1,
                      );
                      return t2;
                    },
                    child: switch (registerFormState) {
                      null => const SizedBox(),
                      _ => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 7.5,
                          ),
                          child: TextFormField(
                            controller: reEnterPasswordCtrl,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              hintText: 'Re-enter password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                    },
                  );
                },
              ),
              const SizedBox(
                height: 30,
              ),
              BlocBuilder<AuthPageBloc, AuthPageState>(
                buildWhen: (previous, current) {
                  // if (current case AuthFormState()) {
                  //   return true;
                  // }
                  // return false;
                  return true;
                },
                builder: (context, state) {
                  final opacity = switch (state) {
                    AuthFormState() => 1.0,
                    _ => 0.0,
                  };
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: opacity,
                        duration: animationDuration,
                        child: ElevatedButton(
                          onPressed: () {
                            final isValid =
                                formKey.currentState?.validate() ?? false;
                            if (!isValid) {
                              return;
                            }
                            bloc.add(
                              SubmitFormEvent(
                                email: emailCtrl.text,
                                password: passwordCtrl.text,
                              ),
                            );
                          },
                          child: Text(
                            'Submit',
                          ),
                        ),
                      ),
                      // const PulsingDotIndicator(),
                      if (state case AuthenticatingState())
                        const CircularProgressIndicator(),
                    ],
                  );
                },
              ),
              const SizedBox(
                height: 15,
              ),
              BlocBuilder<AuthPageBloc, AuthPageState>(
                buildWhen: (previous, current) {
                  if (current case AuthFormState()) {
                    return true;
                  }
                  switch ((previous, current)) {
                    case (AuthFormState(), _):
                      return true;
                    case _:
                  }
                  return false;
                },
                builder: (context, state) {
                  final text = switch (state) {
                    LoginFormState() => 'Register',
                    RegisterFormState() => 'Login',
                    _ => '',
                  };
                  return AnimatedOpacity(
                    opacity: text.isEmpty ? 0 : 1,
                    duration: animationDuration,
                    child: TextButton(
                      onPressed: () {
                        bloc.add(
                          const SwitchAuthEvent(),
                        );
                      },
                      child: Text(
                        text,
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     print('bloc.state: ${bloc.state}');
      //   },
      // ),
    );
    return DismissKeyboard(
      child: scaffold,
    );
  }
}
