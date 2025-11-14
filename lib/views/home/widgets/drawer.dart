import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note_maker/app/blocs/auth/bloc.dart';
import 'package:note_maker/app/blocs/auth/event.dart';
import 'package:note_maker/app/blocs/auth/state.dart';
import 'package:note_maker/utils/extensions/build_context.dart';
import 'package:note_maker/views/settings/route.dart';
import 'package:note_maker/widgets/custom_animated_switcher.dart';

class HomePageDrawer extends StatelessWidget {
  const HomePageDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (previous, current) {
                return previous.runtimeType != current.runtimeType;
              },
              builder: (context, state) {
                final (avatar, text) = switch (state) {
                  AuthenticatedState(
                    :final user,
                  ) =>
                    (
                      Text(
                        user.email
                            .substring(
                              0,
                              1,
                            )
                            .toUpperCase(),
                        style: context.themeData.textTheme.bodyLarge?.copyWith(
                          fontSize: 24,
                        ),
                      ),
                      user.email,
                    ),
                  _ => (
                      Icon(
                        Icons.person,
                      ),
                      'You\'re not signed in',
                    ),
                };
                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      CircleAvatar(
                        minRadius: 25,
                        child: avatar,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Text(
                          text,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(
              indent: 15,
              endIndent: 15,
              height: 1,
            ),
            const SizedBox(
              height: 7.5,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
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
                              icon: const Icon(
                                Icons.login,
                              ),
                              onTap: () {
                                context.go(
                                  '/auth',
                                );
                              },
                            ),
                          AuthenticatedState() => _ListItem(
                              icon: const Icon(
                                Icons.person,
                              ),
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
                    icon: const Icon(
                      Icons.settings,
                    ),
                    onTap: () {
                      const SettingsRoute().go(context);
                    },
                  ),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return switch (state) {
                        AuthenticatedState() => _ListItem(
                            title: 'Sign out',
                            icon: const Icon(
                              Icons.logout,
                            ),
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
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final String title;
  final Icon icon;
  final VoidCallback onTap;

  const _ListItem({
    required this.title,
    required this.icon,
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
          children: [
            icon,
            const SizedBox(
              width: 15,
            ),
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
