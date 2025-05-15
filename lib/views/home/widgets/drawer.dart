import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/blocs/auth/bloc.dart';
import 'package:note_maker/app/blocs/auth/event.dart';
import 'package:note_maker/app/blocs/auth/state.dart';
import 'package:note_maker/widgets/custom_animated_switcher.dart';

class HomePageDrawer extends StatelessWidget {
  const HomePageDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (previous, current) {
                    return previous.runtimeType != current.runtimeType;
                  },
                  builder: (context, state) {
                    return CustomAnimatedSwitcher(
                      child: switch (state) {
                        UnauthenticatedState() => _ListItem(
                            title: 'Sign in',
                            onTap: () {
                              context.go(
                                '/auth',
                              );
                            },
                          ),
                        AuthenticatedState() => _ListItem(
                            title: 'Profile',
                            onTap: () {},
                          ),
                        _ => const SizedBox(),
                      },
                    );
                  },
                ),
                _ListItem(
                  title: 'Settings',
                  onTap: () {},
                ),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return switch (state) {
                      AuthenticatedState() => _ListItem(
                          title: 'Sign out',
                          onTap: () {
                            authBloc.add(
                              const SignOutUserEvent(),
                            );
                          },
                        ),
                      _ => const SizedBox(),
                    };
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _ListItem({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
