import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:note_maker/app/themes/cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const themeModes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            BlocBuilder<ThemeModeCubit, ThemeMode>(
              builder: (context, state) {
                return SegmentedButton(
                  segments: [
                    for (final themeMode in themeModes)
                      ButtonSegment(
                        value: themeMode,
                        label: Text(toBeginningOfSentenceCase(themeMode.name)),
                      ),
                  ],
                  selected: {state},
                  onSelectionChanged: (value) {
                    if (value.toList() case [final value]) {
                      context.read<ThemeModeCubit>().update(value);
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
